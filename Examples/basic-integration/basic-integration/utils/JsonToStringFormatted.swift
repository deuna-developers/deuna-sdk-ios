//
//  JsonToStringFormatted.swift
//  basic-integration
//
//  Created by DEUNA on 2/9/24.
//

import Foundation

extension [String: Any] {
    public func formattedJson() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            return nil
        } catch {
            print("Error converting dictionary to JSON: \(error.localizedDescription)")
            return nil
        }
    }
}
