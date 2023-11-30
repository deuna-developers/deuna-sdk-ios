
public struct CheckoutEventResponse: Codable {
    public var type: CheckoutEventType
    public var data: CheckoutEventResponseData
}


public struct CheckoutEventResponseData: Codable {
    public var order: CheckoutEventResponseOrder
    public var metadata: CheckoutEventResponseOrderMetadata? // Make this optional

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
    public var currency: String?
    public var order_id: String?
    public var status: String?
}

struct Data: Codable {
    struct Order: Codable {
        struct Item: Codable {
            struct Amount: Codable {
                var amount: Int
                var original_amount: Int
                var display_amount: String
                var display_original_amount: String
                var currency: String
                var currency_symbol: String
                var display_total_discount: String
                var total_discount: Int
            }
            
            struct Weight: Codable {
                var weight: Int
                var unit: String
            }
            
            var id: String
            var name: String
            var description: String
            var options: String
            var total_amount: Amount?
            var unit_price: Amount?
            var tax_amount: Amount?
            var quantity: Int
            var uom: String
            var upc: String
            var sku: String
            var isbn: String
            var brand: String
            var manufacturer: String
            var category: String
            var color: String
            var size: String
            var weight: Weight
            var image_url: String
            var details_url: String
            var type: String
            var taxable: Bool
//            var discounts: [Any] = []
            var included_in_subscription: Bool
            var subscription_id: String
        }
        
        struct Payment: Codable {
            struct PaymentData: Codable {
                struct PaymentAmount: Codable {
                    var amount: Int
                    var currency: String
                }

                struct FromCard: Codable {
                    var card_brand: String
                    var first_six: String
                    var last_four: String
                    var bank_name: String
                    var country_iso: String
                }

                struct Merchant: Codable {
                    var store_code: String
                    var id: String
                }

                struct Customer: Codable {
                    var email: String
                    var id: String
                    var first_name: String
                    var last_name: String
                }

                var amount: PaymentAmount
//                var metadata: Any = Any
                var from_card: FromCard
                var updated_at: String
                var method_type: String
                var merchant: Merchant
                var created_at: String
                var id: String
                var processor: String
                var customer: Customer
                var status: String
                var reason: String
                var external_transaction_id: String
            }
        
            var data: PaymentData
        }
        
        var order_id: String
        var currency: String
        var tax_amount: Double
        var items_total_amount: Int
        var sub_total: Double
        var total_amount: Int
        var items: [Item]
//        var discounts: [Any] = []
//        var metadata: [String: Any] = [String: Any]()
        var status: String
        var payment: Payment
        var transaction_id: String
    }
    
    struct Merchant: Codable {
        var id: String
        var name: String
        var code: String
        var country: String
    }

    struct SchemaRegistry: Codable {
        var source: String
        var schemaId: String
        var schema: String
        var registryName: String
    }
    
    struct User: Codable {
        var id: String
        var email: String
        var is_guest: Bool
    }
    
    var order: Order
    var user: User
    var merchant: Merchant
    var checkoutVersion: String
    var schemaRegistry: SchemaRegistry
}



public struct CheckoutEventResponseOrderMetadata: Codable {
    public var errorCode: String?
    public var errorMessage: String?
}


public struct ElementEventResponse: Codable {
    public var type: CheckoutEventType
    public var data: ElementEventResponseData
}

public struct ElementEventResponseData: Codable {
    public var user: ElementEventResponseUser
    public var metadata: ElementEventResponseOrderMetadata? // Make this optional

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
    public var id: String
    public var email: String
    public var first_name: String
    public var last_name: String
}

public struct ElementEventResponseOrderMetadata: Codable {
    public var errorCode: String?
    public var errorMessage: String?
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
    case pointsToWinStarted = "pointsToWinStarted"
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
    case paymentMethodsShowMore = "paymentMethodsShowMore"
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
