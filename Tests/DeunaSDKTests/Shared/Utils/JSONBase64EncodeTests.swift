//
//  JSONBase64EncodeTests.swift
//
//
//  Created by DEUNA on 6/9/24.
//

import XCTest
import Foundation
import DeunaSDK

/// Ensure that the xprops base64 encoding works
final class JSONBase64EncodeTests: XCTestCase {
    
    class NonSerializableObject {}
    
    func testValidDictionaryToBase64() {
        let data: [String: Any] = ["name": "John Doe", "age": 30]
        let jsonString = data.jsonString()

        /// Dictionary is converted to a valid JSON String
        XCTAssertTrue(jsonString == "{\"name\":\"John Doe\",\"age\":30}" || jsonString == "{\"age\":30,\"name\":\"John Doe\"}")

        let encodedString = data.base64String()
        XCTAssertNotNil(encodedString)

        /// decoded base64 String must be the JSON string given from the Dictionary
        let decodedString = String(data: Data(base64Encoded: encodedString!)!, encoding: .utf8)
        XCTAssertEqual(jsonString, decodedString)
    }
    
    func testInvalidDictionaryToBase64() {
        let data: [String: Any] = ["name": "John Doe", "age": NonSerializableObject()]
        let jsonString = data.jsonString()
        XCTAssertNil(jsonString, "jsonString should be nil")
    }
}



