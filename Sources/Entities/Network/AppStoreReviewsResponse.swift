import Foundation

// MARK: - AppStoreReviewsResponse
struct AppStoreReviewsResponse: Codable {
    let reviews: [AppStoreReview]

    enum CodingKeys: String, CodingKey {
        case reviews = "data"
    }
}

// MARK: - Review
struct AppStoreReview: Codable {
    let id: String
    let attributes: ReviewAttributes

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case attributes = "attributes"
    }
}

// MARK: - Attributes
struct ReviewAttributes: Codable {
    let rating: Int
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

// MARK: - Review Extension
extension AppStoreReview {

    var description: String {
        let rating = switch attributes.rating {
            case 5: "★★★★★"
            case 4: "★★★★☆"
            case 3: "★★★☆☆"
            case 2: "★★☆☆☆"
            case 1: "★☆☆☆☆"
            default: "⚝"
        }
        
        
        var dateString: String = ""

        if let date = DateFormatters.iso.date(from: attributes.createdDate) {
            dateString = DateFormatters.humanReadable.string(from: date)
        } 

        return """
        \(dateString), app_name_here, \(attributes.reviewerNickname) \(attributes.territory.unicodeEmojiFlag), \(rating)
        \(attributes.title)
        \(attributes.body)
        """
    }
}
