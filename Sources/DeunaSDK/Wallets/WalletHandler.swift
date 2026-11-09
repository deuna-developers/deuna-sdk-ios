import Foundation

public enum WalletLaunchResult {
    case success([String: Any])
    case error(code: String, message: String)
    case closed
}

internal protocol WalletHandler {
    var provider: WalletProvider { get }

    /// Returns true if this wallet is available on the current device. Called on a background thread.
    func isAvailableOnDevice() -> Bool

    /// Starts the wallet payment flow and returns raw payment data via completion.
    /// Never tokenizes — callers are responsible for tokenization.
    func launch(
        credentials: WalletCredentials,
        completion: @escaping (WalletLaunchResult) -> Void
    )
}

/// Maps each WalletProvider to its handler. Add new wallets here.
internal enum WalletHandlerRegistry {
    static func get(_ provider: WalletProvider) -> WalletHandler? {
        switch provider {
        case .applePay: return ApplePayWalletHandler.shared
        }
    }
}
