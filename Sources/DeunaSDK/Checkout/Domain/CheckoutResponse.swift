//
//  CheckoutResponse.swift
//
//
//  Created on 29/2/24.
//

import Foundation

public struct CheckoutResponse: Codable {
    public var type: CheckoutEvent
    public var data: CheckoutResponseData

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let typeString = try container.decode(String.self, forKey: .type)
        self.type = CheckoutEvent(rawValue: typeString) ?? .custom // Failsafe here

        self.data = try container.decode(CheckoutResponseData.self, forKey: .data)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case data
    }
}


public struct CheckoutResponseData: Codable {
    public var order: CheckoutResponseOrder
    public var metadata: CheckoutResponseOrderMetadata? // Make this optional

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        order = try container.decode(CheckoutResponseOrder.self, forKey: .order)

        // Since `metadata` is now an optional, you can use `decodeIfPresent` without an issue.
        metadata = try container.decodeIfPresent(CheckoutResponseOrderMetadata.self, forKey: .metadata)
    }

    private enum CodingKeys: String, CodingKey {
        case order
        case metadata
    }
}


public struct CheckoutResponseOrder: Codable {
    public var currency: String?
    public var order_id: String?
}


public struct CheckoutResponseOrderMetadata: Codable {
    public var code: String?
    public var reason: String?
}
