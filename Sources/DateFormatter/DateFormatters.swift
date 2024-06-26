import Foundation

class DateFormatters {

    private init() { }

    static let iso = ISO8601DateFormatter()
    static let humanReadable = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "LLLL d, HH:MM"
        return dateFormatter
    }()

}
