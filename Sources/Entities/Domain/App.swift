struct App: Decodable {
    let id: String
    let name: String
    let platform: Platform
    let telegramThreadID: Int?
}
