//
//  DeunaSDK+Loggin.swift
//
//

import Foundation

// Define an enumeration for log levels
internal enum LogLevel: String {
    case debug
    case info
    case warning
    case error
    case critical
}


extension DeunaSDK{
    // MARK: - Internal UI Methods
    internal func log(_ message: String, error : Error? = nil) {
        // Only log if logging is enabled and the level is critical
        if isLoggingEnabled{
            print("[DeunaSDK]: \(message)")
            if let error = error {
                print("[DeunaSDK]: \(error.localizedDescription)")
            }
        }
    }

}
