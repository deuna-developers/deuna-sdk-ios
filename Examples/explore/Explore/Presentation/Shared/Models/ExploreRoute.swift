import DeunaSDK
import Foundation

/// Navigation destinations for post-widget result screens.
enum ExploreRoute: Hashable {
    case paymentSuccess(orderJsonData: Data)
    case saveCardSuccess(cardJsonData: Data)
    case wallets(deunaSDK: DeunaSDK, orderToken: String?, userInfo: DeunaSDK.UserInfo?)

    static func == (lhs: ExploreRoute, rhs: ExploreRoute) -> Bool {
        switch (lhs, rhs) {
        case (.paymentSuccess(let a), .paymentSuccess(let b)): return a == b
        case (.saveCardSuccess(let a), .saveCardSuccess(let b)): return a == b
        case (.wallets, .wallets): return true
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .paymentSuccess(let data): hasher.combine(0); hasher.combine(data)
        case .saveCardSuccess(let data): hasher.combine(1); hasher.combine(data)
        case .wallets: hasher.combine(2)
        }
    }
}
