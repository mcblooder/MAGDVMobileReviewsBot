import AsyncHTTPClient
import Foundation

class TelegramService {

    private init() { }
    
    static func sendMessage(chatID: Int, threadID: Int?, text: String) throws {        
        Logger.verbose { Logger.log("preparing to send message") }
        
        let message = TelegramMessageRequest(chatID: chatID, threadID: threadID, text: text)
        let payload = try JSONEncoder().encode(message)
        Logger.verbose { Logger.log("payload encoded") }
        
        let request = try HTTPClient.Request(
            url: "https://api.telegram.org/bot\(Config.telegramBotToken)/sendMessage",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: .data(payload)
        )
        
        Logger.verbose { Logger.log("request created") }
        let result = try HTTPClient.shared.execute(request: request).wait()
        Logger.verbose { Logger.log("request executed") }
        
        guard result.status == .ok  else {
            Logger.verbose { Logger.log("HTTP NOT OK", result, type: .error) }
            throw TempError()
        }
        Logger.verbose { Logger.log("HTTP OK") }
        
        guard let body = result.body else {
            Logger.verbose { Logger.log("empty body", type: .error) }
            throw TempError()
        }

        let data = Data.from(buffer: body)
        Logger.verbose { Logger.log("trying to decode response") }
        let telegramResponse = try JSONDecoder().decode(TelegramResponse.self, from: data)
        Logger.verbose { Logger.log("response decoded, ok: \(telegramResponse.ok)") }
        
        guard telegramResponse.ok else {
            Logger.verbose { Logger.log("response:", String(data: data, encoding: .utf8) ?? "could not decode", type: .error) }
            throw TempError()
        }
    }
}
