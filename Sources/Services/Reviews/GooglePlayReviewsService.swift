import AsyncHTTPClient
import Foundation

class GooglePlayReviewsService: ReviewsServiceProtocol {

    private init() { }

    static func fetchReviews(app: App) throws -> [Review] {
        guard app.platform == .googlePlay else { return [] }
        guard let googlePlayAuth = Config.app.googlePlayAuth else { 
            Logger.log("No authentication configuration for \(app.platform), check config.json. Skipping...", type: .warning)
            return []
        }
                
        var jwtPayload = JWT.iatExpPayload(lifetime: 20 * 60)
        jwtPayload["iss"] = googlePlayAuth.clientEmail
        jwtPayload["aud"] = "https://oauth2.googleapis.com/token"
        jwtPayload["scope"] = "https://www.googleapis.com/auth/androidpublisher"
        
        let jwtToken: String = try JWT.rs256(pemKey: googlePlayAuth.privateKey, keyId: googlePlayAuth.privateKeyID, payload: jwtPayload)
        
        let accessToken = try oauth2AccessToken(jwtToken: jwtToken)

        let request = try HTTPClient.Request(
            url: "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/\(app.id)/reviews",
            headers: [
                "Authorization": "Bearer \(accessToken)"
            ]
        )

        do {
            let result = try HTTPClient.shared.execute(request: request).wait()

            guard result.status == .ok else {
                Logger.log("Received HTTP error status: \(result.status)", type: .error)
                throw ReviewsServiceError.httpError
            }

            guard let body = result.body else {
                Logger.log("Missing body in HTTP response", type: .error)
                throw ReviewsServiceError.missingBody
            }

            let data = Data.from(buffer: body)
            let googlePlayReviewsResponse = try JSONDecoder().decode(GooglePlayReviewsResponse.self, from: data)

            return googlePlayReviewsResponse.reviews.reversed().compactMap {
                guard let userComment = $0.comments.first?.userComment else { fatalError() }
                
                let createdTimestamp = Int(userComment.lastModified.seconds)
                var createdDate: Date?

                if let createdTimestamp {
                    createdDate = Date(timeIntervalSince1970: TimeInterval(createdTimestamp))
                }

                var appVersion: String?

                if let appVersionName = userComment.appVersionName {
                    if let androidOSVersion = userComment.androidOSVersion {
                        appVersion = "\(appVersionName), API \(androidOSVersion)"
                    } else {
                        appVersion = appVersionName
                    }
                }
                
                return Review(
                    id: $0.reviewID,
                    rating: userComment.starRating,
                    content: userComment.text.trimmingCharacters(in: .whitespacesAndNewlines),
                    reviewerNickname: $0.authorName,
                    createdDate: createdDate,
                    version: appVersion
                )
            }
        } catch {
            Logger.log("Network error occurred: \(error)", type: .error)
            throw ReviewsServiceError.networkError(error)
        }
    }

    private static func oauth2AccessToken(jwtToken: String) throws -> String {
        let accessTokenRequest = AccessTokenRequest(assertion: jwtToken)
        let accessTokenRequestData = try JSONEncoder().encode(accessTokenRequest)

        let request = try HTTPClient.Request(
            url: Config.app.googlePlayAuth.tokenURI,
            method: .POST,
            headers: [
                "Content-Type": "application/json"
            ],
            body: .data(accessTokenRequestData)
        )

        do {
            let result = try HTTPClient.shared.execute(request: request).wait()

            guard result.status == .ok else {
                Logger.log("Error getting access token from Google: \(result.status)", type: .error)
                throw ReviewsServiceError.oauthError
            }

            guard let body = result.body else {
                Logger.verbose { Logger.log("Empty body in access token response", type: .error) }
                throw ReviewsServiceError.oauthError
            }

            let data = Data.from(buffer: body)
            let googleOauthTokenResponse = try JSONDecoder().decode(GoogleOauthTokenResponse.self, from: data)
            return googleOauthTokenResponse.accessToken
        } catch {
            Logger.log("Network error occurred during OAuth token request: \(error)", type: .error)
            throw ReviewsServiceError.networkError(error)
        }
    }
}