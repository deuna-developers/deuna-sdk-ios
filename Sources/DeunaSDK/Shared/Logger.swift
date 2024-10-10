//
//  Logger.swift
//
//

import Foundation

/// Enum defining different log levels: debug, info, warning, and error.
enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    
    // Add a property for emoji representation
     var emoji: String {
       switch self {
       case .debug: return "👀" // Bug emoji for debug
       case .info: return "ℹ️" // Information emoji for info
       case .warning: return "⚠️" // Warning emoji for warning
       case .error: return "❌" // Cross mark emoji for error
       }
     }
}

/// Static class providing functionality for logging messages with different severity levels and colors in the console.
class DeunaLogs {
    /// Variable defining the minimum log level to be printed. Messages with severity level lower than this level will not be printed.
    static var logLevel: LogLevel = .debug
    
    /// Variable indicating whether logging is enabled or disabled.
    static var isEnabled: Bool = true
    
    static func debug(_ message: String) {
        printLog(level: .debug, message: message)
    }
    
    static func info(_ message: String) {
        printLog(level: .info, message: message)
    }
    
    static func warning(_ message: String) {
        printLog(level: .warning, message: message)
    }
    
    static func error(_ message: String) {
        printLog(level: .error, message: message)
    }

    private static func printLog(level: LogLevel, message: String) {
        guard isEnabled else { return }
        let log = "DeunaSDK \(level.emoji) \(level.rawValue): \(message)"
        print(log)
    }
}
