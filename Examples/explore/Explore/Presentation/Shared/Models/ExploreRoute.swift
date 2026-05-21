import Foundation

/// Navigation destinations for post-widget result screens.
enum ExploreRoute: Hashable {
    case paymentSuccess(orderJsonData: Data)
    case saveCardSuccess(cardJsonData: Data)
}
