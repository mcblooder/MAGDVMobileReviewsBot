struct TelegramMessageRequest: Encodable {
    let chatID: Int
    let threadID: Int?
    let text: String
    let parseMode = "HTML"
    
    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case threadID = "message_thread_id"
        case text = "text"
        case parseMode = "parse_mode"
    }
}
