//
//  BuildElementsUrlTests.swift
//
//  Created by DEUNA on 30/4/25.
//

import XCTest
@testable import DeunaSDK

final class BuildElementsUrlTests: XCTestCase {

    private let baseUrl = "https://elements.deuna.com"

    func testUserInfoWithSpacesInFirstNameEncodedCorrectly() {
        let userInfo = DeunaSDK.UserInfo(firstName: "Mary Jane", lastName: "Doe", email: "test@example.com")

        let queryParams: [(String, String)] = [
            (QueryParameters.firstName, userInfo.firstName!.encodeValue()),
            (QueryParameters.lastName, userInfo.lastName!.encodeValue()),
            (QueryParameters.email, userInfo.email.encodeValue()),
        ]
        let url = buildUrl(baseUrl: baseUrl, queryParameters: queryParams)

        XCTAssertNotNil(url)
        XCTAssertTrue(url!.contains("firstName=Mary%20Jane"), "firstName with space must be percent-encoded")
    }

    func testUserInfoWithSpacesInLastNameEncodedCorrectly() {
        let userInfo = DeunaSDK.UserInfo(firstName: "John", lastName: "Van Doe", email: "test@example.com")

        let queryParams: [(String, String)] = [
            (QueryParameters.firstName, userInfo.firstName!.encodeValue()),
            (QueryParameters.lastName, userInfo.lastName!.encodeValue()),
            (QueryParameters.email, userInfo.email.encodeValue()),
        ]
        let url = buildUrl(baseUrl: baseUrl, queryParameters: queryParams)

        XCTAssertNotNil(url)
        XCTAssertTrue(url!.contains("lastName=Van%20Doe"), "lastName with space must be percent-encoded")
    }

    func testUserInfoWithSpacesInBothNamesEncodedCorrectly() {
        let userInfo = DeunaSDK.UserInfo(firstName: "Mary Jane", lastName: "Van Doe", email: "test@example.com")

        let queryParams: [(String, String)] = [
            (QueryParameters.firstName, userInfo.firstName!.encodeValue()),
            (QueryParameters.lastName, userInfo.lastName!.encodeValue()),
            (QueryParameters.email, userInfo.email.encodeValue()),
        ]
        let url = buildUrl(baseUrl: baseUrl, queryParameters: queryParams)

        XCTAssertNotNil(url)
        XCTAssertTrue(url!.contains("firstName=Mary%20Jane"), "firstName with space must be percent-encoded")
        XCTAssertTrue(url!.contains("lastName=Van%20Doe"), "lastName with space must be percent-encoded")
    }

    func testUserInfoEmailOnlyOmitsFirstNameAndLastName() {
        let userInfo = DeunaSDK.UserInfo(email: "test@example.com")

        var queryParams: [(String, String)] = []
        if let firstName = userInfo.firstName {
            queryParams.append((QueryParameters.firstName, firstName.encodeValue()))
        }
        if let lastName = userInfo.lastName {
            queryParams.append((QueryParameters.lastName, lastName.encodeValue()))
        }
        queryParams.append((QueryParameters.email, userInfo.email.encodeValue()))

        let url = buildUrl(baseUrl: baseUrl, queryParameters: queryParams)

        XCTAssertNotNil(url)
        XCTAssertFalse(url!.contains("firstName="), "firstName must not appear in URL when nil")
        XCTAssertFalse(url!.contains("lastName="), "lastName must not appear in URL when nil")
        XCTAssertTrue(url!.contains("email=test%40example.com"), "email must be present and encoded")
    }
}
