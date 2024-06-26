import Foundation

class Logger {
    
    enum `Type` {
        case info, warning, error
        
        var prefix: String {
            switch self {
            case .info:
                return ""
            case .warning:
                return "\u{001B}[0;33m"
            case .error:
                return "\u{001B}[0;31m"
            }
        }
        
        var postfix: String {
            switch self {
            case .info:
                return ""
            case .warning:
                return "\u{001B}[0m"
            case .error:
                return "\u{001B}[0m"
            }
        }
    }
    
    private init() { }
    
    static func log(_ items: Any..., file: String = #fileID, separator: String = " ", terminator: String = "\n", type: Type = .info) {
        let timestamp = UInt(Date().timeIntervalSince1970 * 1000)
        let logPrefix = type.prefix + "LOG(\(timestamp))[\(file)]  "
        
        print([logPrefix] + items + [type.postfix], separator: separator, terminator: terminator)
    }
    
    static func verbose(_ closure: (() -> Void)) {
        guard Config.verbose else { return }
        closure()
    }
}
