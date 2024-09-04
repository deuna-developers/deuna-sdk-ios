//
//  File.swift
//
//
//  Created by deuna on 20/8/24.
//

import Foundation

func buildUrl(baseUrl: String, queryParameters: [String: String]) -> String? {
    guard var urlComponents = URLComponents(string: baseUrl) else {
        return nil
    }

    urlComponents.queryItems = queryParameters.map {
        URLQueryItem(name: $0.key, value: $0.value)
    }
    return urlComponents.url?.absoluteString
}
