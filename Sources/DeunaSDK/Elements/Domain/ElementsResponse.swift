//
//  ElementsResponse.swift
//
//
//  Created on 29/2/24.
//

import Foundation

public struct ElementsResponse: Codable {
    public var type: ElementsEvent
    public var data: ElementsResponseData
}

public struct ElementsResponseData: Codable {
    public var user: ElementsResponseUser
    public var metadata: ElementsResponseOrderMetadata? // Make this optional

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decode(ElementsResponseUser.self, forKey: .user)

        // Since `metadata` is now an optional, you can use `decodeIfPresent` without an issue.
        metadata = try container.decodeIfPresent(ElementsResponseOrderMetadata.self, forKey: .metadata)
    }

    private enum CodingKeys: String, CodingKey {
        case user
        case metadata
    }
}

public struct ElementsResponseUser: Codable {
    public var id: String
    public var email: String
    public var first_name: String
    public var last_name: String
}

public struct ElementsResponseOrderMetadata: Codable {
    public var errorCode: String?
    public var errorMessage: String?
}
