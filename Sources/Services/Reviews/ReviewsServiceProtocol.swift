import AsyncHTTPClient

protocol ReviewsServiceProtocol {
    static func fetchReviews(app: App) throws -> [Review]
}

enum ReviewsServiceError: Error {
    case httpError
    case missingBody
    case decodingError
    case networkError(Error)
    case oauthError
}