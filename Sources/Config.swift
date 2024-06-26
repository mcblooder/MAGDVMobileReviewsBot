import Foundation

class Config {

    private init() { }

    static let databaseFilename: String = "./database/db.sqlite"

//    static let telegramBotToken: String = {
//        guard let token: String = ProcessInfo.processInfo.environment["MAGDV_REVIEWS_BOT_TOKEN"] else {
//            fatalError("MAGDV_REVIEWS_BOT_TOKEN not set in environment variables")
//        }
//        return token
//    }()
    
    static let telegramBotToken = "7387911920:AAEadNh0e6vjdONPKrzwo9EnROp9PwN3l7w"
    
    static let chatID: Int = -1002157652922
    static let messageSendMaxRetries: UInt = 3
    static let messageSendDelay: TimeInterval = 0.25
    static let messageSendRetryDelay: TimeInterval = 60
    
    static var verbose: Bool = false
}
