import AsyncHTTPClient
import Foundation

enum TelegramServiceError: Error {
    case httpError
    case missingBody
    case decodingError
    case telegramAPIError(description: String)
    case networkError(Error)
}

class TelegramService {

    private init() { }
    
    static func sendMessage(chatID: Int, threadID: Int?, text: String, isVerbose: Bool = false) throws {        
        Logger.verbose { Logger.log("Preparing to send message", type: .info) }
        
        let message = TelegramMessageRequest(chatID: chatID, threadID: threadID, text: text)
        let payload = try JSONEncoder().encode(message)
        Logger.verbose { Logger.log("Payload encoded", type: .info) }
        
        let request = try HTTPClient.Request(
            url: "https://api.telegram.org/bot\(Config.app.telegram.botToken)/sendMessage",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: .data(payload)
        )
        
        Logger.verbose { Logger.log("Request created", type: .info) }
        let result = try HTTPClient.shared.execute(request: request).wait()
        Logger.verbose { Logger.log("Request executed", type: .info) }
        
        guard result.status == .ok else {
            Logger.log("HTTP status not OK: \(result.status)", type: .error)
            if isVerbose {
                Logger.verbose { Logger.log("HTTP status not OK", result, type: .error) }
            }
            throw TelegramServiceError.httpError
        }
        Logger.verbose { Logger.log("HTTP OK", type: .info) }
        
        guard let body = result.body else {
            Logger.log("Empty body in HTTP response", type: .error)
            if isVerbose {
                Logger.verbose { Logger.log("Empty body", type: .error) }
            }
            throw TelegramServiceError.missingBody
        }

        let data = Data.from(buffer: body)
        Logger.verbose { Logger.log("Trying to decode response", type: .info) }
        do {
            let telegramResponse = try JSONDecoder().decode(TelegramResponse.self, from: data)
            Logger.verbose { Logger.log("Response decoded, OK: \(telegramResponse.ok)", type: .info) }
            
            guard telegramResponse.ok else {
                let responseString = String(data: data, encoding: .utf8) ?? "Could not decode response"
                Logger.log("Telegram API error: \(responseString)", type: .error)
                if isVerbose {
                    Logger.verbose { Logger.log("Response: \(responseString)", type: .error) }
                }
                throw TelegramServiceError.telegramAPIError(description: responseString)
            }
        } catch {
            Logger.log("Decoding error: \(error)", type: .error)
            if isVerbose {
                Logger.verbose { Logger.log("Decoding error", type: .error) }
            }
            throw TelegramServiceError.decodingError
        }
    }
}