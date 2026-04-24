import DeunaSDK
import Foundation

/// Shared widget-level helper values and defaults used while building SDK configurations.
struct WidgetDefinitions {
    func tokenOrNil(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    func splitPaymentBehavior(enabled: Bool) -> Json? {
        guard enabled else { return nil }
        return [
            "paymentMethods": [
                "creditCard": [
                    "splitPayments": [
                        "maxCards": 2
                    ],
                    "flow": "purchase",
                ]
            ]
        ]
    }

    func fallbackUserInfoIfNeeded(_ userToken: String) -> DeunaSDK.UserInfo? {
        guard tokenOrNil(userToken) == nil else {
            return nil
        }
        return DeunaSDK.UserInfo(
            firstName: "John",
            lastName: "Doe",
            email: "johndoe@example.com"
        )
    }
}
