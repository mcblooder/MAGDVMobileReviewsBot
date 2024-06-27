// This file was generated from JSON Schema using quicktype, do not modify it directly.

import Foundation

// MARK: - AppStoreReviewsResponse
struct AppStoreReviewsResponse: Decodable {
    let reviews: [AppStoreReview]

    enum CodingKeys: String, CodingKey {
        case reviews = "data"
    }
}

// MARK: - AppStoreReview
struct AppStoreReview: Decodable {
    let id: String
    let attributes: AppStoreReviewAttributes

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case attributes = "attributes"
    }
}

// MARK: - AppStoreReviewAttributes
struct AppStoreReviewAttributes: Decodable {
    let rating: UInt8
    let title: String
    let body: String
    let reviewerNickname: String
    let createdDate: String
    let territory: String

    enum CodingKeys: String, CodingKey {
        case rating = "rating"
        case title = "title"
        case body = "body"
        case reviewerNickname = "reviewerNickname"
        case createdDate = "createdDate"
        case territory = "territory"
    }
}