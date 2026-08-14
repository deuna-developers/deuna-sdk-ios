import Foundation

internal enum VaultResponseParser {

    struct ProvidersResult {
        let providers: [WalletProvider]
        let credentials: [WalletProvider: WalletCredentials]
    }

    struct FetchResult {
        let credentials: [WalletProvider: WalletCredentials]
        let userToken: String?
        let userId: String?
    }

    static func parseProviders(_ json: [String: Any]) -> ProvidersResult {
        guard let methods = json["paymentMethods"] as? [[String: Any]] else {
            return ProvidersResult(providers: [], credentials: [:])
        }
        let merchant = (json["checkout"] as? [String: Any])?["merchant"] as? [String: Any]
        var providers: [WalletProvider] = []
        var credentialsMap: [WalletProvider: WalletCredentials] = [:]

        for method in methods {
            guard
                let processorName = method["processor_name"] as? String,
                let provider = WalletProvider.fromProcessorName(processorName),
                !providers.contains(provider)
            else { continue }

            providers.append(provider)
            switch provider {
            case .applePay:
                credentialsMap[.applePay] = parseApplePayCredentials(method: method, merchant: merchant)
            }
        }
        return ProvidersResult(providers: providers, credentials: credentialsMap)
    }

    static func parseFetchResult(_ json: [String: Any]) -> FetchResult {
        let checkout = json["checkout"] as? [String: Any]
        let merchant = checkout?["merchant"] as? [String: Any]
        let order = (checkout?["order"] as? [String: Any])?["order"] as? [String: Any]
        let userAuthData = (json["userAuthResponse"] as? [String: Any])?["data"] as? [String: Any]

        var credentialsMap: [WalletProvider: WalletCredentials] = [:]
        if let methods = json["paymentMethods"] as? [[String: Any]] {
            for method in methods {
                guard
                    let processorName = method["processor_name"] as? String,
                    let provider = WalletProvider.fromProcessorName(processorName)
                else { continue }
                switch provider {
                case .applePay:
                    credentialsMap[.applePay] = parseApplePayCredentials(method: method, merchant: merchant, order: order)
                }
            }
        }

        let userToken = (userAuthData?["user_token"] as? String)?.nonEmpty
        let userId = (userAuthData?["user_id"] as? String)?.nonEmpty

        return FetchResult(credentials: credentialsMap, userToken: userToken, userId: userId)
    }

    static func buildUserInfoBody(_ userInfo: DeunaSDK.UserInfo?) -> [String: Any]? {
        guard let userInfo = userInfo, !userInfo.email.isEmpty else { return nil }
        var body: [String: Any] = ["email": userInfo.email]
        if userInfo.firstName?.isEmpty == false { body["firstName"] = userInfo.firstName }
        if userInfo.lastName?.isEmpty == false { body["lastName"] = userInfo.lastName }
        return body
    }

    private static func parseApplePayCredentials(
        method: [String: Any],
        merchant: [String: Any]?,
        order: [String: Any]? = nil
    ) -> ApplePayCredentials {
        let credentials = method["credentials"] as? [String: Any] ?? [:]
        let extraParams = method["extra_params"] as? [String: Any] ?? [:]

        let merchantIdentifier = (extraParams["mobile_merchant_id"] as? String) ?? ""
        let displayName = (extraParams["merchant_name"] as? String)
            ?? (merchant?["name"] as? String)
            ?? ""

        let networks = (extraParams["allowed_card_networks"] as? [String])
            ?? ApplePayCredentials.defaultNetworks
        let capabilities = (extraParams["allowed_auth_methods"] as? [String])
            ?? ApplePayCredentials.defaultCapabilities

        let transactionInfo = parseTransactionInfo(order: order, merchant: merchant, label: displayName)
        let credentialId = (method["id"] as? String)?.nonEmpty

        return ApplePayCredentials(
            merchantIdentifier: merchantIdentifier,
            displayName: displayName,
            supportedNetworks: networks,
            merchantCapabilities: capabilities,
            transactionInfo: transactionInfo,
            credentialId: credentialId
        )
    }

    private static func parseTransactionInfo(
        order: [String: Any]?,
        merchant: [String: Any]?,
        label: String
    ) -> ApplePayCredentials.TransactionInfo? {
        guard
            let currency = (order?["currency"] as? String)?.nonEmpty,
            let country = (merchant?["country"] as? String)?.nonEmpty
        else { return nil }

        let totalCents = order?["total_amount"] as? Int ?? 0
        let amount = String(format: "%.2f", Double(totalCents) / 100.0)

        return ApplePayCredentials.TransactionInfo(
            amount: amount,
            currencyCode: currency.uppercased(),
            countryCode: country.uppercased(),
            label: label
        )
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
