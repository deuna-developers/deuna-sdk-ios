//
//  File.swift
//
//
//  Created by deuna on 20/8/24.
//

import Foundation

public extension [[String: Any]] {
    func toEncodeBase64() -> String? {
        do {
            // 1. Serialize to JSON
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            // 2. Convert to Data
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return nil
            }
            // 3. Encode to Base64
            return jsonString.data(using: .utf8)?.base64EncodedString()
        } catch {
            DeunaLogs.error("Error converting array to Base64: \(error.localizedDescription)")
            return nil
        }
    }
}


public extension [String: Any] {
    func toEncodeBase64() -> String? {
        do {
            // 1. Serialize to JSON
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            // 2. Convert to Data
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return nil
            }
            // 3. Encode to Base64
            return jsonString.data(using: .utf8)?.base64EncodedString()
        } catch {
            DeunaLogs.error("Error converting JSON to Base64: \(error.localizedDescription)")
            return nil
        }
    }
}

