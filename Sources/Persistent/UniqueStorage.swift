import Foundation
import SQLite

class UniqueStorage {

    static let shared = UniqueStorage()

    private let db: Connection

    private let id = Expression<String>("id")
    private let uniqueIdsTable = Table("unique_ids")

    private init() {
        do {
            Logger.log("Initializing...")
            var fileURL = URL(fileURLWithPath: Config.databaseFilename)
            
            if fileURL.pathComponents.count > 1 {
                fileURL.deleteLastPathComponent()
                try? FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true)
            }
            
            db = try Connection(Config.databaseFilename)
            Logger.log("Connected")
            try createTable()
        } catch {
            Logger.log("Database init error: \(error)", type: .error)
            fatalError()
        }
    }

    private func createTable() throws {
        try db.run(uniqueIdsTable.create(ifNotExists: true) { t in
            Logger.log("Creating table")
            t.column(id, primaryKey: true)
        })
    }

    func isExist(uniqueId: String) -> Bool {       
        do {
            let query = uniqueIdsTable.filter(id == uniqueId)
            let count = try db.scalar(query.count)
            return count > 0
        } catch {
            Logger.log("Failed to check unique ID in table: \(error)", type: .error)
            fatalError()
        }
    }
    
    @discardableResult
    func add(uniqueId: String) -> Bool {
        do {
            try db.run(uniqueIdsTable.insert(or: .ignore, id <- uniqueId))
            return true
        } catch {
            Logger.log("Failed to add unique ID to table: \(error)", type: .error)
            fatalError()
        }
    }
}
