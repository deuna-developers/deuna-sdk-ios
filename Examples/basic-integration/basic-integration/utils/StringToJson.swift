//
//  StringToJson.swift
//  basic-integration
//
//  Created by DEUNA on 2/9/24.
//

import Foundation

extension String {
    func toDictionary() -> [String: Any]? {
        guard let data = data(using: .utf8) else {
            return nil
        }

        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return dictionary
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}
