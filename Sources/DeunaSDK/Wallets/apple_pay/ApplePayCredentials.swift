import Foundation

internal struct ApplePayCredentials: WalletCredentials {
    let merchantIdentifier: String
    let displayName: String
    let supportedNetworks: [String]     // raw strings from API e.g. ["VISA", "MASTERCARD"]
    let merchantCapabilities: [String]  // raw strings from API e.g. ["CRYPTOGRAM_3DS"]
    let transactionInfo: TransactionInfo?
    let credentialId: String?

    struct TransactionInfo {
        let amount: String
        let currencyCode: String
        let countryCode: String
        let label: String
    }

    static let defaultNetworks = ["VISA", "MASTERCARD", "AMEX", "DISCOVER"]
    static let defaultCapabilities = ["CRYPTOGRAM_3DS"]
}

