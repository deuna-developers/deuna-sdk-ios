//
//  Errors.swift
//
//
//  Created by Darwin on 29/2/24.
//

import Foundation

// MARK: - Custom Errors

public struct PaymentsError {
    public let type: ErrorType
    public let metadata: ErrorMetadata?
    public let order: [String: Any]?

    public init(type: ErrorType, metadata: ErrorMetadata? = nil, order: [String: Any]? = nil) {
        self.type = type
        self.metadata = metadata
        self.order = order
    }

    public struct ErrorMetadata {
        public let code: String
        public let message: String
    }

    public enum ErrorType: Error {
        case noInternetConnection
        case invalidOrderToken
        case initializationFailed
        case errorWhileLoadingTheURL
        case orderNotFound
        case orderCouldNotBeRetrieved
        case paymentError
        case userError
        case unknownError

        var message: String {
            switch self {
            case .noInternetConnection:
                return PaymentsErrorMessages.noInternetConnection
            case .initializationFailed:
                return "Failed to initialize the widget"
            case .invalidOrderToken:
                return "Invalid orderToken"
            case .orderNotFound:
                return "Order not found"
            case .orderCouldNotBeRetrieved:
                return PaymentsErrorMessages.orderCouldNotBeRetrieved
            case .paymentError:
                return "An error ocurred while processing payment"
            case .userError:
                  return "An error ocurred related to the user authentication"
            case .errorWhileLoadingTheURL:
                return LoadUrlErrorMessages.unknown
            case .unknownError:
                return "An uknown error ocurred"
            }
        }
    }

    public static func fromJson(data: Json) -> PaymentsError? {
        guard
            let metadata = data["metadata"] as? Json,
            let order = data["order"] as? Json
        else {
            return nil
        }

        let errorCode = metadata["errorCode"] as? String
        let errorMessage = metadata["errorMessage"] as? String

        if errorCode == nil || errorMessage == nil {
            DeunaLogs.error("Missing errorCode or errorMessage")
            DeunaLogs.warning("\(metadata)")
        }

        return PaymentsError(
            type: .paymentError,
            metadata: PaymentsError.ErrorMetadata(
                code: errorCode ?? ErrorCodes.unknown,
                message: errorMessage ?? ErrorMessages.unknown
            ),
            order: order
        )
    }
}

public struct ElementsError {
    public var type: ErrorType
    public let metadata: ErrorMetadata?
    public var user: Json?

    init(type: ErrorType, metadata: ErrorMetadata? = nil, user: Json? = nil) {
        self.type = type
        self.metadata = metadata
        self.user = user
    }

    public struct ErrorMetadata {
        public let code: String
        public let message: String
    }

    public enum ErrorType: String {
        case noInternetConnection
        case initializationFailed
        case userError
        case invalidUserToken
        case unknownError
        case vaultSaveError
        case vaultFailed

        var message: String {
            switch self {
            case .initializationFailed:
                return "Failed to initialize the widget"
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

    public static func fromJson(type: ErrorType, data: Json) -> ElementsError? {
        guard let metadata = data["metadata"] as? Json else {
            return nil
        }

        let errorCode = metadata["errorCode"] as? String
        let errorMessage = metadata["errorMessage"] as? String

        if errorCode == nil || errorMessage == nil {
            DeunaLogs.error("Missing errorCode or errorMessage")
            DeunaLogs.warning("\(metadata)")
        }

        let user = data["user"] as? Json

        return ElementsError(
            type: type,
            metadata: ElementsError.ErrorMetadata(
                code: errorCode ?? ErrorCodes.unknown,
                message: errorMessage ?? ErrorMessages.unknown
            ),
            user: user
        )
    }
}
