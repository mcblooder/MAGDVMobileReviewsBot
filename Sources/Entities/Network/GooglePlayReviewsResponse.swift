// This file was generated from JSON Schema using quicktype, do not modify it directly.

import Foundation

// MARK: - GooglePlayReviewsResponse
struct GooglePlayReviewsResponse: Decodable {
    let reviews: [GooglePlayReview]

    enum CodingKeys: String, CodingKey {
        case reviews = "reviews"
    }
}

// MARK: - GooglePlayReview
struct GooglePlayReview: Decodable {
    let reviewID: String
    let authorName: String
    let comments: [GooglePlayComment]

    enum CodingKeys: String, CodingKey {
        case reviewID = "reviewId"
        case authorName = "authorName"
        case comments = "comments"
    }
}

// MARK: - GooglePlayComment
struct GooglePlayComment: Decodable {
    let userComment: GooglePlayUserComment

    enum CodingKeys: String, CodingKey {
        case userComment = "userComment"
    }
}

// MARK: - GooglePlayUserComment
struct GooglePlayUserComment: Decodable {
    let text: String
    let lastModified: GooglePlayLastModified
    let starRating: UInt8
    let androidOSVersion: Int?
    let appVersionCode: Int?
    let appVersionName: String?

    enum CodingKeys: String, CodingKey {
        case text = "text"
        case lastModified = "lastModified"
        case starRating = "starRating"
        case androidOSVersion = "androidOsVersion"
        case appVersionCode = "appVersionCode"
        case appVersionName = "appVersionName"
    }
}

// MARK: - GooglePlayLastModified
struct GooglePlayLastModified: Decodable {
    let seconds: String

    enum CodingKeys: String, CodingKey {
        case seconds = "seconds"
    }
}