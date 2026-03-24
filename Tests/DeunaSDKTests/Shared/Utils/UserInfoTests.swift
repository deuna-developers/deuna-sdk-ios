//
//  UserInfoTests.swift
//  
//
//  Created by DEUNA on 6/9/24.
//

import XCTest
import DeunaSDK

/// Tests to validate that an instance of UserInfo has valid properties."
final class UserInfoTests: XCTestCase {
    func testUserInfoEmptyFirstName() {
       let userInfo = DeunaSDK.UserInfo(firstName: "", lastName: "Doe", email: "valid@example.com")
       XCTAssertFalse(userInfo.isValidFirstName)
     }

     func testUserInfoEmptyLastName() {
       let userInfo = DeunaSDK.UserInfo(firstName: "John", lastName: "", email: "valid@example.com")
       XCTAssertFalse(userInfo.isValidLastName)
     }

     func testUserInfoInvalidEmailMissingAtSymbol() {
       let userInfo = DeunaSDK.UserInfo(firstName: "John", lastName: "Doe", email: "invalidemail.com")
       XCTAssertFalse(userInfo.isValidEmail)
     }

     func testUserInfoInvalidEmailMissingTLD() {
       let userInfo = DeunaSDK.UserInfo(firstName: "John", lastName: "Doe", email: "valid@example")
       XCTAssertFalse(userInfo.isValidEmail)
     }

     func testUserInfoInvalidEmailInvalidCharacters() {
       let userInfo = DeunaSDK.UserInfo(firstName: "John", lastName: "Doe", email: "invalid)email@example.com")
       XCTAssertFalse(userInfo.isValidEmail)
     }

     func testUserInfoValidEmail() {
       let userInfo = DeunaSDK.UserInfo(firstName: "John", lastName: "Doe", email: "valid@example.com")
       XCTAssertTrue(userInfo.isValidEmail)
     }

     func testUserInfoAllValid() {
       let userInfo = DeunaSDK.UserInfo(firstName: "John", lastName: "Doe", email: "valid+10@example.com")
       XCTAssertTrue(userInfo.isValidUserInfo)
     }
}
