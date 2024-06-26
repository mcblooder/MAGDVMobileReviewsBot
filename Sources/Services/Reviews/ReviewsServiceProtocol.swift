
protocol ReviewsServiceProtocol {
    static func fetchReviews(app: App) throws -> [Review]
}
