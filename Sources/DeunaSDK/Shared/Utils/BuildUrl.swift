//
//  File.swift
//
//
//  Created by DEUNA on 20/8/24.
//

import Foundation

public func buildUrl(baseUrl: String, queryParameters: [(String, String)]) -> String? {
    guard !baseUrl.isEmpty else {
        return nil
    }
    
    guard let urlComponents = URLComponents(string: baseUrl) else {
        return nil
    }
    
    // Prepare custom encoding replacements
    let charactersToReplace: [Character: String] = [
        "+": "%2B",
        "@": "%40",
        "&": "%26",
        "=":"%3D"
    ]
    
    // Encode and construct query parameters while preserving order
    var queryList: [String] = []
    for (key, value) in queryParameters {
        let encodedValue = value
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .reduce(into: "") { result, character in
                if let replacement = charactersToReplace[character] {
                    result += replacement
                } else {
                    result.append(character)
                }
            } ?? ""
        queryList.append("\(key)=\(encodedValue)")
    }
       
    // Join query items
    let query = queryList.joined(separator: "&")
       
    // Append query to URL
    let separator = urlComponents.queryItems?.isEmpty ?? true ? "?" : "&"
    
    return "\(baseUrl)\(separator)\(query)"
}
