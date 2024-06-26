import Foundation
import Crypto

// Helper extension to encode Data to Base64URL string
extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// Struct to represent JWT Header
struct JWTHeader: Codable {
    let alg: String = "ES256"
    let kid: String
}

// Struct to represent JWT Payload
struct JWTPayload: Codable {
    let iss: String
    let iat: Int
    let exp: Int
}

func generateJWT2(authKey: String, keyId: String, teamId: String) -> String? {
    // JWT Header
    let header = JWTHeader(kid: keyId)
    
    // JWT Payload
    let iat = Int(Date().timeIntervalSince1970)
    let exp = iat + 20 * 60  // Token valid for 20 minutes
    let payload = JWTPayload(iss: teamId, iat: iat, exp: exp)
    
    // Encode Header and Payload to JSON and then to Base64URL
    guard let headerData = try? JSONEncoder().encode(header),
          let payloadData = try? JSONEncoder().encode(payload) else {
        return nil
    }
    
    let headerBase64 = headerData.base64URLEncodedString()
    let payloadBase64 = payloadData.base64URLEncodedString()
    
    let jwtString = "\(headerBase64).\(payloadBase64)"
    
    // Decode the P8 private key from base64
    guard let privateKeyData = Data(base64Encoded: authKey.replacingOccurrences(of: "\n", with: ""), options: .ignoreUnknownCharacters) else {
        return nil
    }
    
    // Create a private key from the private key data
    guard let privateKey = try? P256.Signing.PrivateKey(rawRepresentation: privateKeyData) else {
        return nil
    }
    
    // Sign the JWT
    guard let signature = try? privateKey.signature(for: Data(jwtString.utf8)) else {
        return nil
    }
    
    let signatureBase64 = signature.derRepresentation.base64URLEncodedString()
    
    return "\(jwtString).\(signatureBase64)"
}

func generateJWT(authKey: String, keyId: String, teamId: String) -> String? {
    // JWT Header
    let header: [String: Any] = [
        "alg": "ES256",
        "kid": keyId
    ]
    
    // JWT Payload
    let payload: [String: Any] = [
        "iss": teamId,
        "iat": Int(Date().timeIntervalSince1970),
        "exp": Int(Date().timeIntervalSince1970 + 20 * 60),  // Token valid for 20 minutes
        "aud": "appstoreconnect-v1"
    ]
    
    // Encode Header and Payload to JSON and then to Base64
    guard let headerData = try? JSONSerialization.data(withJSONObject: header, options: []),
          let payloadData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
        print("DBG::1")
        return nil
    }

    print("DBG::header::", String(data: headerData, encoding: .utf8)!)
    print("DBG::payload::", String(data: payloadData, encoding: .utf8)!)
    
    let headerBase64 = headerData.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    
    let payloadBase64 = payloadData.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    
    let jwtString = "\(headerBase64).\(payloadBase64)"
    
    print("DBG::", authKey.replacingOccurrences(of: "\n", with: "").count)
    // Decode the P8 private key from base64
    guard let privateKeyData = Data(base64Encoded: authKey.replacingOccurrences(of: "\n", with: ""), options: .ignoreUnknownCharacters) else {
        print("DBG::2")
        return nil
    }

    // var privateKeyData = try! Data.init(contentsOf: URL(fileURLWithPath: "AuthKey_MR9G8ULX3M.p8"))
    print("DBG::privateKeyData::", privateKeyData)
    
    // Create a SecKey from the private key data
    let privateKey = try? P256.Signing.PrivateKey(pemRepresentation: authKey)
    
    
    guard let signature = try? privateKey?.signature(for: Data(jwtString.utf8)) else {
        print("DBG::3")
        return nil
    }

    print("DBG::2::", jwtString)

    
    let signatureBase64 = signature.rawRepresentation.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    
    return "\(jwtString).\(signatureBase64)"
}


class ReviewsNotifyTask {

    private init() { }
    
    static let reviewsServices: [Platform: ReviewsServiceProtocol.Type] = [
        .appStore: AppStoreReviewsService.self
    ]

    static func run() {
        Logger.log("Starting reviews notify task")
        
        let apps = [
            App(id: "1498375434", name: "Ярче Плюс", platform: .appStore, telegramThreadID: 2),
            App(id: "1408647025", name: "KDV Online", platform: .appStore, telegramThreadID: 4),
            App(id: "com.yarche.app", name: "Ярче Плюс", platform: .googlePlay, telegramThreadID: 7),
            App(id: "com.magonline.app", name: "KDV Online", platform: .googlePlay, telegramThreadID: 9)
        ]
        
        for app in apps {
            Logger.log("Collecting reviews for \(app.name)/\(app.platform)")
            
            guard let reviewsService = reviewsServices[app.platform] else {
                Logger.log("No reviews service for \(app.platform), skipping...")
                continue
            }
            
            do {
                let reviews = try reviewsService.fetchReviews(app: app).filter {
                    return UniqueStorage.shared.isExist(uniqueId: $0.uniqueId(for: app)) == false
                }
                
                Logger.log("Found \(reviews.count) new reviews for \(app.name)/\(app.platform)")
                guard reviews.count > 0 else { continue }
                
                Logger.log("Sending telegram messages for \(app.name)/\(app.platform)")
                for (index, review) in reviews.enumerated() {
                    Logger.log("\(app.name)/\(app.platform) - Reviews \(index + 1)/\(reviews.count)")
                    sendMessages(app: app, review: review)
                }
            } catch {
                Logger.log("Error collecting reviews for \(app.name)/\(app.platform):\n\(error)")
            }
        }
    }
    
    private static func sendMessages(app: App, review: Review, retryCounter: UInt = 0) {
        Logger.verbose { Logger.log("Sending telegram message for reviewID: \(review.id)") }
        do {
            if retryCounter == 0 {
                Thread.sleep(forTimeInterval: Config.messageSendDelay)
            }
            
            let text = review.htmlDescription(for: app)
            
            try TelegramService.sendMessage(chatID: Config.chatID, threadID: app.telegramThreadID, text: text)
            Logger.verbose { Logger.log("Sent telegram message for reviewID: \(review.id)") }
            UniqueStorage.shared.add(uniqueId: review.uniqueId(for: app))
        } catch {
            guard retryCounter < Config.messageSendMaxRetries else {
                Logger.verbose { Logger.log("Error sending telegram message for reviewID: \(review.id):\n\(error)", type: .error) }
                return
            }
            
            Logger.verbose { Logger.log("Error sending telegram message for reviewID: \(review.id):\n\(error)\nRetrying \(retryCounter + 1)/\(Config.messageSendMaxRetries)...", type: .error) }
            Thread.sleep(forTimeInterval: Config.messageSendRetryDelay)
            sendMessages(app: app, review: review, retryCounter: retryCounter + 1)
        }
    }
}
