import Foundation

extension DeunaSDK {

    /// Returns true if the given wallet provider is available on this device.
    /// Does NOT make any network calls.
    public static func isWalletAvailableOnDevice(
        provider: String,
        environment: Environment
    ) -> Bool {
        guard let p = WalletProvider.fromProcessorName(provider) else { return false }
        return WalletHandlerRegistry.get(p)?.isAvailableOnDevice() ?? false
    }

    /// Launches the wallet payment sheet using pre-fetched credentials from the caller.
    /// Returns raw payment data — no tokenization is performed.
    /// No vault API call is made — the caller is responsible for fetching credentials.
    public func launchWallet(
        provider: String,
        credentials: [String: Any],
        completion: @escaping (WalletLaunchResult) -> Void
    ) {
        guard let walletProvider = WalletProvider.fromProcessorName(provider) else {
            completion(.error(code: "UNSUPPORTED_WALLET", message: "Unknown wallet provider: \(provider)"))
            return
        }

        let walletCredentials: WalletCredentials
        switch walletProvider {
        case .applePay:
            walletCredentials = Self.parseApplePayCredentials(credentials)
        }

        guard let handler = WalletHandlerRegistry.get(walletProvider) else {
            completion(.error(code: "NO_HANDLER", message: "No handler registered for \(provider)"))
            return
        }

        handler.launch(credentials: walletCredentials) { result in
            DispatchQueue.main.async { completion(result) }
        }
    }

    static func parseApplePayCredentials(_ dict: [String: Any]) -> ApplePayCredentials {
        let ti = dict["transactionInfo"] as? [String: Any]
        return ApplePayCredentials(
            merchantIdentifier: dict["merchantIdentifier"] as? String ?? "",
            displayName: dict["displayName"] as? String ?? "",
            supportedNetworks: dict["supportedNetworks"] as? [String] ?? ApplePayCredentials.defaultNetworks,
            merchantCapabilities: dict["merchantCapabilities"] as? [String] ?? ApplePayCredentials.defaultCapabilities,
            transactionInfo: ti.map {
                ApplePayCredentials.TransactionInfo(
                    amount: $0["amount"] as? String ?? "0.00",
                    currencyCode: $0["currencyCode"] as? String ?? "",
                    countryCode: $0["countryCode"] as? String ?? "",
                    label: $0["label"] as? String ?? ""
                )
            },
            credentialId: dict["credentialId"] as? String
        )
    }
}
