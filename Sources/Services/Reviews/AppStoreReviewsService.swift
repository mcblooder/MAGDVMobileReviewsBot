import AsyncHTTPClient
import Foundation

class AppStoreReviewsService: ReviewsServiceProtocol {

    private init() { }

    static func fetchReviews(app: App) throws -> [Review] {
        guard app.platform == .appStore else { return [] }
        guard let appStoreAuth = Config.app.appStoreAuth else { 
            Logger.log("No authentication configuration for \(app.platform), check config.json. Skipping...", type: .warning)
            return []
        }

        var jwtPayload = JWT.iatExpPayload(lifetime: 20 * 60)
        jwtPayload["iss"] = appStoreAuth.issuer
        jwtPayload["aud"] = "appstoreconnect-v1"
        
        let jwtToken: String = try JWT.es256(pemKey: appStoreAuth.privateKey, keyId: appStoreAuth.privateKeyID, payload: jwtPayload)
        
        let request = try HTTPClient.Request(
            url: "https://api.appstoreconnect.apple.com/v1/apps/\(app.id)/customerReviews?sort=-createdDate",
            headers: [
                "Authorization": "Bearer \(jwtToken)"
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
            let appStoreReviewsResponse = try JSONDecoder().decode(AppStoreReviewsResponse.self, from: data)

            return appStoreReviewsResponse.reviews.reversed().map {
                return Review(
                    id: $0.id,
                    rating: $0.attributes.rating,
                    content: $0.attributes.body,
                    reviewerNickname: $0.attributes.reviewerNickname,
                    title: $0.attributes.title,
                    createdDate: DateFormatters.iso.date(from: $0.attributes.createdDate),
                    country: $0.attributes.territory
                )
            }
        } catch {
            Logger.log("Network error occurred: \(error)", type: .error)
            throw ReviewsServiceError.networkError(error)
        }
    }
}