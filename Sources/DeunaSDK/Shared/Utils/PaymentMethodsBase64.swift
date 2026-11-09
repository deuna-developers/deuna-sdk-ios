//
//  File.swift
//
//
//  Created by DEUNA on 20/8/24.
//

import Foundation

public extension Collection {
    func jsonString() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else {
            DeunaLogs.error("Invalid JSON object")
            return nil
        }

        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: [])
        return String(data: jsonData, encoding: .utf8)
    }

    func base64String() -> String? {
        return self.jsonString()?.base64()
    }
}

public extension String {
    func base64() -> String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
}
