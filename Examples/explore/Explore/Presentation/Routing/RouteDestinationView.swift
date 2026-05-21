import Foundation
import SwiftUI

/// Resolves navigation routes into concrete success screens after widget completion.
struct ExploreRouteDestinationView: View {
    let route: ExploreRoute

    var body: some View {
        switch route {
        case .paymentSuccess(let orderJsonData):
            if let orderJson = try? JSONSerialization.jsonObject(with: orderJsonData) as? [String: Any] {
                PaymentSuccessView(order: orderJson)
            }
        case .saveCardSuccess(let cardJsonData):
            if let cardJson = try? JSONSerialization.jsonObject(with: cardJsonData) as? [String: Any] {
                CardSavedSuccessView(savedCardData: cardJson)
            }
        }
    }
}
