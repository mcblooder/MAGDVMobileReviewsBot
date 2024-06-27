import Foundation

struct Review {
    
    let id: String
    let rating: UInt8
    let content: String
    let reviewerNickname: String?
    let title: String?
    let createdDate: Date?
    let version: String?
    let country: String?

    init(
        id: String,
        rating: UInt8,
        content: String,
        reviewerNickname: String? = nil,
        title: String? = nil,
        createdDate: Date? = nil,
        version: String? = nil,
        country: String? = nil
    ) {
        self.id = id
        self.rating = rating
        self.content = content
        self.reviewerNickname = reviewerNickname
        self.title = title
        self.createdDate = createdDate
        self.version = version
        self.country = country 
    }
}

extension Review {
    
    func uniqueId(for app: App) -> String {
        return "\(app.platform.rawValue)_\(app.id)_\(id)"
    }
    
    // TODO: Make this templatable
    func htmlDescription(for app: App) -> String {
        let rating = switch rating {
            case 5: "★★★★★"
            case 4: "★★★★☆"
            case 3: "★★★☆☆"
            case 2: "★★☆☆☆"
            case 1: "★☆☆☆☆"
            default: "⚝"
        }
        
        
        let dateString: String
        
        if let createdDate {
            dateString = DateFormatters.humanReadable.string(from: createdDate)
        } else {
            dateString = ""
        }

        // DateFormatters.iso.date(from: createdDate)
        return """
        \(rating) \(version ?? "")
        <b>\(dateString)</b>, \(reviewerNickname ?? "") \(country?.unicodeEmojiFlag ?? "")
        
        <b>\(title?.appending("\n") ?? "")</b>
        \(content)
        """
    }
}
