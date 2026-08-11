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

    guard var urlComponents = URLComponents(string: baseUrl) else {
        return nil
    }

    let queryString = queryParameters.map { key, value in
        "\(key)=\(value)" // No aplicamos percent-encoding aquí
    }.joined(separator: "&")

    urlComponents.percentEncodedQuery = queryString
    return urlComponents.url?.absoluteString
}

extension String {
    func encodeValue() -> String {
        // Prepare custom encoding replacements
        let charactersToReplace: [Character: String] = [
            "+": "%2B",
            "@": "%40",
            "&": "%26",
            "=": "%3D"
        ]

        // Encode and construct query parameters while preserving order
        let encodedValue = addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .reduce(into: "") { result, character in
                if let replacement = charactersToReplace[character] {
                    result += replacement
                } else {
                    result.append(character)
                }
            } ?? ""

        return encodedValue
    }
}
