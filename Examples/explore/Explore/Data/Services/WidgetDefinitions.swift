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

    func fallbackUserInfoIfNeeded(_ config: ExploreConfig) -> DeunaSDK.UserInfo? {
        guard tokenOrNil(config.userToken) == nil else { return nil }
        let email = config.userInfoEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else { return nil }
        let firstName = config.userInfoFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = config.userInfoLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        if firstName.isEmpty && lastName.isEmpty {
            return DeunaSDK.UserInfo(email: email)
        } else {
            return DeunaSDK.UserInfo(firstName: firstName, lastName: lastName, email: email)
        }
    }
}
