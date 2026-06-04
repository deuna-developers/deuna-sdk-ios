import Foundation

/// Enumerates all widgets that can be tested from the Explore example app.
enum ExploreWidget: String, CaseIterable, Identifiable, Codable {
    case paymentWidget
    case checkoutWidget
    case vaultWidget
    case nextActionWidget
    case voucherWidget
    case clickToPayWidget

    var id: String { rawValue }

    var title: String {
        switch self {
        case .paymentWidget: return "Payment Widget"
        case .checkoutWidget: return "Checkout Widget"
        case .vaultWidget: return "Vault Widget"
        case .nextActionWidget: return "Next Action"
        case .voucherWidget: return "Voucher"
        case .clickToPayWidget: return "Click to Pay"
        }
    }
}
