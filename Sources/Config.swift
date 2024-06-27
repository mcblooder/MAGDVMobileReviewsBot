import Foundation

class Config {

    private init() { }

    static let databaseFilename: String = "./data/db.sqlite"
    static var app: AppConfig!

    static var verbose: Bool = false   

    static func load() {
        do {
            let configData = try Data(contentsOf: URL(fileURLWithPath: "./data/config.json"))
            Config.app = try JSONDecoder().decode(AppConfig.self, from: configData)
        } catch {
            Logger.log("Error parsing ./data/config.json: \(error)", type: .error)
            fatalError()
        }
    }
}
