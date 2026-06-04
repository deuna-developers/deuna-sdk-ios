import Foundation

public struct WalletsError {
    public let code: String
    public let message: String

    static func fetchFailed(_ cause: String) -> WalletsError {
        return WalletsError(code: "WALLETS_FETCH_FAILED", message: cause)
    }
}
