//
//  BuildUrlTests.swift
//  
//
//  Created by deuna on 6/9/24.
//

import XCTest
import DeunaSDK

final class BuildUrlTests: XCTestCase {
    func testBuildUrlWithEncodedQueryParameters() {
            let baseUrl = "https://example.com/api?version=v1.0.0"
            let queryParameters = [("name", "John Doe"), ("city", "New York")]

            let expectedUrl = "https://example.com/api?version=v1.0.0&name=John%20Doe&city=New%20York"
            let resultUrl = buildUrl(baseUrl: baseUrl, queryParameters: queryParameters)

            XCTAssertEqual(resultUrl, expectedUrl, "URL with encoded query parameters is incorrect")
        }

        func testBuildUrlWithSpecialCharacters() {
            let baseUrl = "https://example.com/api"
            let queryParameters = [("query", "hello+world & more")]

            let expectedUrl = "https://example.com/api?query=hello%2Bworld%20%26%20more"
            let resultUrl = buildUrl(baseUrl: baseUrl, queryParameters: queryParameters)

            XCTAssertEqual(resultUrl, expectedUrl, "URL with special characters should be properly encoded")
        }

        func testBuildUrlWithEmptyQueryParameters() {
            let baseUrl = "https://example.com/api"
            let queryParameters: [(String, String)] = []

            let expectedUrl = "https://example.com/api?"
            let resultUrl = buildUrl(baseUrl: baseUrl, queryParameters: queryParameters)

            XCTAssertEqual(resultUrl, expectedUrl, "URL should not have query parameters when the dictionary is empty")
        }

        func testBuildUrlWithNilBaseUrl() {
            let baseUrl = ""
            let queryParameters = [("key", "value")]

            let resultUrl = buildUrl(baseUrl: baseUrl, queryParameters: queryParameters)
            XCTAssertNil(resultUrl, "URL should be nil if baseUrl is invalid")
        }

        func testBuildUrlWithInvalidCharacters() {
            let baseUrl = "https://example.com/api"
            let queryParameters = [("email", "test+10@test.com")]

            let expectedUrl = "https://example.com/api?email=test%2B10%40test.com"
            let resultUrl = buildUrl(baseUrl: baseUrl, queryParameters: queryParameters)

            XCTAssertEqual(resultUrl, expectedUrl, "URL with special characters should be properly encoded")
        }
}
