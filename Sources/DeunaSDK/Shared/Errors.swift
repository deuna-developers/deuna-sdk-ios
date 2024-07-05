//
//  Errors.swift
//
//
//  Created by Darwin on 29/2/24.
//

import Foundation

// MARK: - Custom Errors


public enum PaymentWidgetsErrorType: Error {
    case noInternetConnection
    case invalidOrderToken
    case initializationFailed
    case orderNotFound
    case paymentError
    case unknownError

    var message: String {
        switch self {
        case .noInternetConnection:
            return "No internet connection available"
        case .initializationFailed:
            return "Failed to initialize the checkout"
        case .invalidOrderToken:
            return "initCheckout was called using an invalid orderToken"
        case .orderNotFound:
            return "Order not found"
        case .paymentError:
            return "An error ocurred while processing payment"
        case .unknownError:
            return "An uknown error ocurred"
        }
    }
}


public enum CheckoutErrorType: Error {
    case noInternetConnection
    case invalidOrderToken
    case checkoutInitializationFailed
    case orderNotFound
    case paymentError
    case userError
    case orderError
    case unknownError

    var message: String {
        switch self {
        case .noInternetConnection:
            return "No internet connection available"
        case .checkoutInitializationFailed:
            return "Failed to initialize the checkout"
        case .invalidOrderToken:
            return "initCheckout was called using an invalid orderToken"
        case .orderNotFound:
            return "Order not found"
        case .paymentError:
            return "An error ocurred while processing payment"
        case .userError:
            return "An error ocurred related to the user authentication"
        case .orderError:
            return "An order related error ocurred"
        case .unknownError:
            return "An uknown error ocurred"
        }
    }
}

public enum ElementsErrorType: String {
    case noInternetConnection = "noInternetConnection"
    case userError = "userError"
    case invalidUserToken = "invalidUserToken"
    case unknownError = "unknownError"
    case vaultSaveError = "vaultSaveError"
    case vaultFailed = "vaultFailed"

    var message: String {
        switch self {
        case .noInternetConnection:
            return "No internet connection available"
        case .userError:
            return "An error ocurred related to the user authentication"
        case .invalidUserToken:
            return "initElements was called using an invalid userToken"
        case .unknownError:
            return "An uknown error ocurred"
        case .vaultSaveError:
            return "Vault save error"
        case .vaultFailed:
            return "Vault failed"
        }
    }
}

// Make sure CheckoutErrorType conforms to Codable if needed
extension CheckoutErrorType: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let errorString = try container.decode(String.self)

        switch errorString {
        case "No internet connection available":
            self = .noInternetConnection
        case "Failed to initialize the checkout":
            self = .checkoutInitializationFailed
        // Add other cases as needed
        default:
            self = .unknownError
        }
    }
}

extension ElementsErrorType: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let errorString = try container.decode(String.self)

        switch errorString {
        case "No internet connection available":
            self = .noInternetConnection
        // Add other cases as needed
        default:
            self = .unknownError
        }
    }
}

public struct CheckoutError {
    public var type: CheckoutErrorType
    public var order: CheckoutResponseOrder?
    public var user: ElementsResponseUser?

    private enum CodingKeys: String, CodingKey {
        case message
        case type = "error_type"
        case order
        case user
    }

    init(type: CheckoutErrorType, order: CheckoutResponseOrder? = nil, user: ElementsResponseUser? = nil) {
        self.type = type
        self.order = order
        self.user = user
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode `type` as a `CheckoutErrorType`
        type = try container.decode(CheckoutErrorType.self, forKey: .type)

        // Decode `order` only if it exists
        order = try container.decodeIfPresent(CheckoutResponseOrder.self, forKey: .order)

        user = try container.decodeIfPresent(ElementsResponseUser.self, forKey: .user)
    }
}

public struct ElementsError {
    public var type: ElementsErrorType
    public var user: ElementsResponseUser?

    private enum CodingKeys: String, CodingKey {
        case message
        case type = "error_type"
        case user
    }

    init(type: ElementsErrorType, user: ElementsResponseUser? = nil) {
        self.type = type
        self.user = user
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode `type` as a `ElementsErrorType`
        type = try container.decode(ElementsErrorType.self, forKey: .type)

        user = try container.decodeIfPresent(ElementsResponseUser.self, forKey: .user)
    }
}
