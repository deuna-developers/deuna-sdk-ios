import Foundation

/// Converts SDK callback payloads into app navigation routes.
final class ResultRouter {
    private let appendRoute: (ExploreRoute) -> Void

    init(appendRoute: @escaping (ExploreRoute) -> Void) {
        self.appendRoute = appendRoute
    }

    func routePaymentSuccess(payload: [String: Any]) {
        DispatchQueue.main.async {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
                return
            }
            self.appendRoute(.paymentSuccess(orderJsonData: jsonData))
        }
    }

    func routeSaveCardSuccess(payload: [String: Any]) {
        DispatchQueue.main.async {
            guard let metadata = payload["metadata"] as? [String: Any],
                let savedCardData = metadata["createdCard"] as? [String: Any],
                let jsonData = try? JSONSerialization.data(withJSONObject: savedCardData)
            else {
                return
            }
            self.appendRoute(.saveCardSuccess(cardJsonData: jsonData))
        }
    }
}
