
public struct CheckoutEventResponse: Codable {
    var type: CheckoutEventType
    var data: CheckoutEventResponseData
}


public struct CheckoutEventResponseData: Codable {
    var order: CheckoutEventResponseOrder
    var metadata: CheckoutEventResponseOrderMetadata? // Make this optional

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        order = try container.decode(CheckoutEventResponseOrder.self, forKey: .order)

        // Since `metadata` is now an optional, you can use `decodeIfPresent` without an issue.
        metadata = try container.decodeIfPresent(CheckoutEventResponseOrderMetadata.self, forKey: .metadata)
    }

    private enum CodingKeys: String, CodingKey {
        case order
        case metadata
    }
}

public struct CheckoutEventResponseOrder: Codable {
    var currency: String?
    var order_id: String?
    var status: String?
}

public struct CheckoutEventResponseOrderMetadata: Codable {
    var errorCode: String?
    var errorMessage: String?
}


public struct ElementEventResponse: Codable {
    var type: CheckoutEventType
    var data: ElementEventResponseData
}

public struct ElementEventResponseData: Codable {
    var user: ElementEventResponseUser
    var metadata: ElementEventResponseOrderMetadata? // Make this optional

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decode(ElementEventResponseUser.self, forKey: .user)

        // Since `metadata` is now an optional, you can use `decodeIfPresent` without an issue.
        metadata = try container.decodeIfPresent(ElementEventResponseOrderMetadata.self, forKey: .metadata)
    }

    private enum CodingKeys: String, CodingKey {
        case user
        case metadata
    }
}

public struct ElementEventResponseUser: Codable {
    var id: String
    var email: String
    var first_name: String
    var last_name: String
}

public struct ElementEventResponseOrderMetadata: Codable {
    var errorCode: String?
    var errorMessage: String?
}

public struct DeUnaErrorMessage {
    var message: String
    var type: DeunaSDKError
    var order: CheckoutEventResponseOrder?
    var user: ElementEventResponseUser?

    private enum CodingKeys: String, CodingKey {
        case message
        case type = "error_type"
        case order
        case user
    }

    init(message: String, type: DeunaSDKError, order: CheckoutEventResponseOrder? = nil, user: ElementEventResponseUser? = nil) {
            self.message = message
            self.type = type
            self.order = order
            self.user = user
        }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        
        // Decode `type` as a `DeunaSDKError`
        type = try container.decode(DeunaSDKError.self, forKey: .type)
        
        // Decode `order` only if it exists
        order = try container.decodeIfPresent(CheckoutEventResponseOrder.self, forKey: .order)
        
        user = try container.decodeIfPresent(ElementEventResponseUser.self, forKey: .user)
    }
}

// MARK: - Custom Errors
public enum DeunaSDKError: Error {
    case noInternetConnection
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



public enum CheckoutEventType: String, Codable {
    case purchase = "purchase"
    case purchaseError = "purchaseError"
    case linkClose = "linkClose"
    case linkFailed = "linkFailed"
    case purchaseRejected = "purchaseRejected"
    case paymentProcessing = "paymentProcessing"
    case paymentMethodsAddCard = "paymentMethodsAddCard"
    case paymentMethodsCardExpirationDateInitiated = "paymentMethodsCardExpirationDateInitiated"
    case paymentMethodsCardNameEntered = "paymentMethodsCardNameEntered"
    case apmSuccess = "apmSuccess"
    case changeAddress = "changeAddress"
    case paymentClick = "paymentClick"
    case apmClickRedirect = "apmClickRedirect"
    case paymentMethodsCardNumberInitiated = "paymentMethodsCardNumberInitiated"
    case paymentMethodsCardNumberEntered = "paymentMethodsCardNumberEntered"
    case paymentMethodsEntered = "paymentMethodsEntered"
    case checkoutStarted = "checkoutStarted"
    case linkStarted = "linkStarted"
    case paymentMethodsStarted = "paymentMethodsStarted"
    case paymentMethodsSelected = "paymentMethodsSelected"
    case adBlock = "adBlock"
    case paymentMethods3dsInitiated = "paymentMethods3dsInitiated"
    case paymentMethodsCardSecurityCodeInitiated = "paymentMethodsCardSecurityCodeInitiated"
    case paymentMethodsCardSecurityCodeEntered = "paymentMethodsCardSecurityCodeEntered"
    case paymentMethodsCardExpirationDateEntered = "paymentMethodsCardExpirationDateEntered"
    case paymentMethodsCardNameInitiated = "paymentMethodsCardNameInitiated"
    case vaultSaveError = "vaultSaveError"
    case vaultSaveSuccess = "vaultSaveSuccess"
    case vaultFailed = "vaultFailed"
    case vaultStarted = "vaultStarted"
    case vaultSaveClick = "vaultSaveClick"
    case vaultProcessing = "vaultProcessing"
    case vaultClosed = "vaultClosed"
    case vaultRedirect3DS = "vaultRedirect3DS"
    case paymentMethodsNotAvailable = "paymentMethodsNotAvailable"
}


// Make sure DeunaSDKError conforms to Codable if needed
extension DeunaSDKError: Codable {
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
