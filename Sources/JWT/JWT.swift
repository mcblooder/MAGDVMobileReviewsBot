import _CryptoExtras
import Crypto
import Foundation

enum JWTError: Error {
    case jsonSerializationError
    case invalidPrivateKey
    case signingError
}

class JWT {

    private init() { }

    static func iatExpPayload(lifetime: TimeInterval) -> [String: Any] {
        if lifetime > 20 * 60 {
            Logger.log("Lifetime over 20 minutes is not recommended", type: .warning)
        }

        return [
            "iat": Int(Date().timeIntervalSince1970),
            "exp": Int(Date().timeIntervalSince1970 + lifetime)
        ]
    }

    static func es256(pemKey: String, keyId: String, payload: [String: Any]) throws -> String {
        let header: [String: Any] = [
            "alg": "ES256",
            "kid": keyId,
            "typ": "JWT"
        ]

        do {
            let headerData = try JSONSerialization.data(withJSONObject: header, options: [])
            let payloadData = try JSONSerialization.data(withJSONObject: payload, options: [])

            let jwtString = "\(headerData.base64URLEncodedString()).\(payloadData.base64URLEncodedString())"

            guard let privateKey = try? P256.Signing.PrivateKey(pemRepresentation: pemKey) else {
                Logger.log("Invalid Private Key", type: .error)
                throw JWTError.invalidPrivateKey
            }

            let signature = try privateKey.signature(for: Data(jwtString.utf8))

            return "\(jwtString).\(signature.rawRepresentation.base64URLEncodedString())"
        } catch {
            switch error {
            case is JWTError:
                Logger.log("JWT Error: \(error)", type: .error)
                throw error
            case is DecodingError:
                Logger.log("JSON Serialization Error: \(error)", type: .error)
                throw JWTError.jsonSerializationError
            case is CryptoKitError:
                Logger.log("Signing Error: \(error)", type: .error)
                throw JWTError.signingError
            default:
                Logger.log("Unexpected Error: \(error)", type: .error)
                throw error
            }
        }
    }

    static func rs256(pemKey: String, keyId: String, payload: [String: Any]) throws -> String {
        let header: [String: Any] = [
            "alg": "RS256",
            "kid": keyId,
            "typ": "JWT"
        ]

        do {
            let headerData = try JSONSerialization.data(withJSONObject: header, options: [])
            let payloadData = try JSONSerialization.data(withJSONObject: payload, options: [])

            let jwtString = "\(headerData.base64URLEncodedString()).\(payloadData.base64URLEncodedString())"

            guard let privateKey = try? _CryptoExtras._RSA.Signing.PrivateKey(pemRepresentation: pemKey) else {
                Logger.log("Invalid Private Key", type: .error)
                throw JWTError.invalidPrivateKey
            }

            let signature = try privateKey.signature(for: Data(jwtString.utf8), padding: .insecurePKCS1v1_5)

            return "\(jwtString).\(signature.rawRepresentation.base64URLEncodedString())"
        } catch {
            switch error {
            case is JWTError:
                Logger.log("JWT Error: \(error)", type: .error)
                throw error
            case is DecodingError:
                Logger.log("JSON Serialization Error: \(error)", type: .error)
                throw JWTError.jsonSerializationError
            case is CryptoKitError:
                Logger.log("Signing Error: \(error)", type: .error)
                throw JWTError.signingError
            default:
                Logger.log("Unexpected Error: \(error)", type: .error)
                throw error
            }
        }
    }
}

fileprivate extension Data {

    /// See https://tools.ietf.org/html/rfc7515#section-2
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    }
}