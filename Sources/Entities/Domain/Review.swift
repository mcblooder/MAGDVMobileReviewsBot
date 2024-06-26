import Foundation

struct Review {
    let id: String
    let rating: UInt8
    let content: String

    let reviewerNickname: String?
    let title: String?
    let createdDate: Date?
    let country: String?
}

extension Review {
    
    func uniqueId(for app: App) -> String {
        return "\(app.platform.rawValue)_\(app.id)_\(id)"
    }
    
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
        \(rating)
        <b>\(dateString)</b>, \(reviewerNickname ?? "") \(country?.unicodeEmojiFlag ?? "")
        
        <b>\(title?.appending("\n") ?? "")</b>
        \(content)
        """
    }
}
