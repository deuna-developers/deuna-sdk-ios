import Foundation

/// Standalone wallet launcher — no DeunaSDK instance required.
/// Used by @deuna/react-native-sdk native module.
public class DeunaWalletLauncher: NSObject {

    /// Returns true if the given provider is available on the current device.
    /// Does NOT make any network calls.
    public static func isAvailable(provider: String) -> Bool {
        guard let p = WalletProvider.fromProcessorName(provider) else { return false }
        return WalletHandlerRegistry.get(p)?.isAvailableOnDevice() ?? false
    }

    /// Launches the wallet payment sheet and returns raw payment data via completion.
    /// No tokenization — caller is responsible for POST to /users/{id}/cards.
    public static func launch(
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
            walletCredentials = DeunaSDK.parseApplePayCredentials(credentials)
        }

        guard let handler = WalletHandlerRegistry.get(walletProvider) else {
            completion(.error(code: "NO_HANDLER", message: "No handler registered for \(provider)"))
            return
        }

        handler.launch(credentials: walletCredentials, completion: completion)
    }
}
