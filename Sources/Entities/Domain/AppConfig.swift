import Foundation

struct AppConfig: Decodable {
    let apps: [App]
    let appStoreAuth: AppStoreAuth!
    let googlePlayAuth: GooglePlayAuth!
    let telegram: TelegramConfig
    let dateFormatterLocale: String?

    enum CodingKeys: String, CodingKey {
        case apps = "apps"
        case appStoreAuth = "appStoreAuth"
        case googlePlayAuth = "googlePlayAuth"
        case telegram = "telegram"
        case dateFormatterLocale = "dateFormatterLocale"
    }
}

struct AppStoreAuth: Decodable {
    let privateKeyID: String
    let privateKey: String
    let issuer: String

    enum CodingKeys: String, CodingKey {
        case privateKeyID = "private_key_id"
        case privateKey = "private_key"
        case issuer = "issuer"
    }
}

struct GooglePlayAuth: Codable {
    let privateKeyID: String
    let privateKey: String
    let clientEmail: String
    let tokenURI: String

    enum CodingKeys: String, CodingKey {
        case privateKeyID = "private_key_id"
        case privateKey = "private_key"
        case clientEmail = "client_email"
        case tokenURI = "token_uri"
    }
}

struct TelegramConfig: Codable {
    let chatID: Int
    let botToken: String
    let messageSendMaxRetries: Int
    let messageSendDelay: TimeInterval
    let messageSendRetryDelay: TimeInterval

    enum CodingKeys: String, CodingKey {
        case chatID = "chatID"
        case botToken = "botToken"
        case messageSendMaxRetries = "messageSendMaxRetries"
        case messageSendDelay = "messageSendDelay"
        case messageSendRetryDelay = "messageSendRetryDelay"
    }
}
