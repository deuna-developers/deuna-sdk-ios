import DeunaSDK
import Foundation

/// Shared widget-level helper values and defaults used while building SDK configurations.
struct WidgetDefinitions {
    func tokenOrNil(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    func domainOrNil(_ value: String) -> String? {
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

    /// Builds the behavior.paymentMethods.apms override for mercadopago_wallet from the
    /// drawer's callback URL fields. Returns nil when none are set, so the SDK's
    /// behavior param is simply omitted (unchanged default behavior).
    func apmBehaviorOverride(_ config: ExploreConfig) -> Json? {
        guard !config.callbackUrlSuccess.isEmpty || !config.callbackUrlCanceled.isEmpty
            || !config.callbackUrlPending.isEmpty
        else {
            return nil
        }
        var callbackUrls: Json = [:]
        if !config.callbackUrlSuccess.isEmpty { callbackUrls["onSuccess"] = config.callbackUrlSuccess }
        if !config.callbackUrlCanceled.isEmpty { callbackUrls["onCanceled"] = config.callbackUrlCanceled }
        if !config.callbackUrlPending.isEmpty { callbackUrls["onPending"] = config.callbackUrlPending }
        return [
            "paymentMethods": [
                "apms": [
                    "mercadopago_wallet": [
                        "callbackUrls": callbackUrls
                    ]
                ]
            ]
        ]
    }

    /// Shallow-merges "paymentMethods" from each behavior dict that is set.
    func mergeBehavior(_ behaviors: Json?...) -> Json? {
        let present = behaviors.compactMap { $0 }
        guard !present.isEmpty else { return nil }
        if present.count == 1 { return present[0] }
        var mergedPaymentMethods: Json = [:]
        for behavior in present {
            if let pm = behavior["paymentMethods"] as? Json {
                mergedPaymentMethods.merge(pm) { _, new in new }
            }
        }
        return ["paymentMethods": mergedPaymentMethods]
    }

    func fallbackUserInfoIfNeeded(_ config: ExploreConfig) -> DeunaSDK.UserInfo? {
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
