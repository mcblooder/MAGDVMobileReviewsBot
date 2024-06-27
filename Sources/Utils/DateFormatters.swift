import Foundation

class DateFormatters {

    private init() { }

    static let iso = ISO8601DateFormatter()
    static let humanReadable = {
        let dateFormatter = DateFormatter()
        
        if let localeIdentifier = Config.app.dateFormatterLocale {
            dateFormatter.locale = Locale(identifier: localeIdentifier)
        }
        
        dateFormatter.dateFormat = "LLLL d, HH:MM"
        return dateFormatter
    }()
}
