import Foundation

/// Persisted source-of-truth configuration used to initialize and run SDK widgets.
struct IntegrationConfig: Codable {
    var environment: ExploreEnvironment
    var privateKey: String
    var publicKey: String
    var orderToken: String
    var userToken: String
    var fraudId: String
    var fraudProvidersJson: String
    var merchantName: String
    var merchantCountryCode: String
    var merchantCurrencyCode: String
    var hidePayButton: Bool
    var enableSplitPayment: Bool
    var presentationMode: ExplorePresentationMode
    var selectedWidget: ExploreWidget
    var userInfoFirstName: String
    var userInfoLastName: String
    var userInfoEmail: String

    static let `default` = IntegrationConfig(
        environment: .sandbox,
        privateKey: "",
        publicKey: "YOUR_PUBLIC_API_KEY",
        orderToken: "",
        userToken: "",
        fraudId: "",
        fraudProvidersJson: """
            {
              "CYBERSOURCE": {
                "orgId": "your_org_id",
                "merchantId": "your_merchant_id"
              },
              "RISKIFIED": {
                "storeDomain": "your_domain.com"
              }
            }
            """,
        merchantName: "",
        merchantCountryCode: "US",
        merchantCurrencyCode: "USD",
        hidePayButton: true,
        enableSplitPayment: false,
        presentationMode: .modal,
        selectedWidget: .paymentWidget,
        userInfoFirstName: "",
        userInfoLastName: "",
        userInfoEmail: ""
    )

    enum CodingKeys: String, CodingKey {
        case environment
        case privateKey
        case publicKey
        case orderToken
        case userToken
        case fraudId
        case fraudProvidersJson
        case merchantName
        case merchantCountryCode
        case merchantCurrencyCode
        case hidePayButton
        case enableSplitPayment
        case presentationMode
        case selectedWidget
        case userInfoFirstName
        case userInfoLastName
        case userInfoEmail
    }

    init(
        environment: ExploreEnvironment,
        privateKey: String,
        publicKey: String,
        orderToken: String,
        userToken: String,
        fraudId: String,
        fraudProvidersJson: String,
        merchantName: String,
        merchantCountryCode: String,
        merchantCurrencyCode: String,
        hidePayButton: Bool,
        enableSplitPayment: Bool,
        presentationMode: ExplorePresentationMode,
        selectedWidget: ExploreWidget,
        userInfoFirstName: String = "",
        userInfoLastName: String = "",
        userInfoEmail: String = ""
    ) {
        self.environment = environment
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.orderToken = orderToken
        self.userToken = userToken
        self.fraudId = fraudId
        self.fraudProvidersJson = fraudProvidersJson
        self.merchantName = merchantName
        self.merchantCountryCode = merchantCountryCode
        self.merchantCurrencyCode = merchantCurrencyCode
        self.hidePayButton = hidePayButton
        self.enableSplitPayment = enableSplitPayment
        self.presentationMode = presentationMode
        self.selectedWidget = selectedWidget
        self.userInfoFirstName = userInfoFirstName
        self.userInfoLastName = userInfoLastName
        self.userInfoEmail = userInfoEmail
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = IntegrationConfig.default
        environment =
            try container.decodeIfPresent(ExploreEnvironment.self, forKey: .environment)
            ?? defaults.environment
        privateKey =
            try container.decodeIfPresent(String.self, forKey: .privateKey) ?? defaults.privateKey
        publicKey = try container.decodeIfPresent(String.self, forKey: .publicKey) ?? defaults.publicKey
        orderToken =
            try container.decodeIfPresent(String.self, forKey: .orderToken) ?? defaults.orderToken
        userToken = try container.decodeIfPresent(String.self, forKey: .userToken) ?? defaults.userToken
        fraudId = try container.decodeIfPresent(String.self, forKey: .fraudId) ?? defaults.fraudId
        fraudProvidersJson =
            try container.decodeIfPresent(String.self, forKey: .fraudProvidersJson)
            ?? defaults.fraudProvidersJson
        merchantName =
            try container.decodeIfPresent(String.self, forKey: .merchantName) ?? defaults.merchantName
        merchantCountryCode =
            try container.decodeIfPresent(String.self, forKey: .merchantCountryCode)
            ?? defaults.merchantCountryCode
        merchantCurrencyCode =
            try container.decodeIfPresent(String.self, forKey: .merchantCurrencyCode)
            ?? defaults.merchantCurrencyCode
        hidePayButton =
            try container.decodeIfPresent(Bool.self, forKey: .hidePayButton) ?? defaults.hidePayButton
        enableSplitPayment =
            try container.decodeIfPresent(Bool.self, forKey: .enableSplitPayment)
            ?? defaults.enableSplitPayment
        presentationMode =
            try container.decodeIfPresent(ExplorePresentationMode.self, forKey: .presentationMode)
            ?? defaults.presentationMode
        selectedWidget =
            try container.decodeIfPresent(ExploreWidget.self, forKey: .selectedWidget)
            ?? defaults.selectedWidget
        userInfoFirstName =
            try container.decodeIfPresent(String.self, forKey: .userInfoFirstName) ?? defaults.userInfoFirstName
        userInfoLastName =
            try container.decodeIfPresent(String.self, forKey: .userInfoLastName) ?? defaults.userInfoLastName
        userInfoEmail =
            try container.decodeIfPresent(String.self, forKey: .userInfoEmail) ?? defaults.userInfoEmail
    }
}

/// Backward-compatible alias used by current UI and tests.
typealias ExploreConfig = IntegrationConfig

/// Editable copy of the applied configuration used by the drawer before pressing "Explorar".
struct ExploreDraftConfig {
    var environment: ExploreEnvironment
    var privateKey: String
    var publicKey: String
    var orderToken: String
    var userToken: String
    var fraudId: String
    var fraudProvidersJson: String
    var merchantName: String
    var merchantCountryCode: String
    var merchantCurrencyCode: String
    var hidePayButton: Bool
    var enableSplitPayment: Bool
    var presentationMode: ExplorePresentationMode
    var selectedWidget: ExploreWidget
    var userInfoFirstName: String
    var userInfoLastName: String
    var userInfoEmail: String

    init(from config: ExploreConfig) {
        environment = config.environment
        privateKey = config.privateKey
        publicKey = config.publicKey
        orderToken = config.orderToken
        userToken = config.userToken
        fraudId = config.fraudId
        fraudProvidersJson = config.fraudProvidersJson
        merchantName = config.merchantName
        merchantCountryCode = config.merchantCountryCode
        merchantCurrencyCode = config.merchantCurrencyCode
        hidePayButton = config.hidePayButton
        enableSplitPayment = config.enableSplitPayment
        presentationMode = config.presentationMode
        selectedWidget = config.selectedWidget
        userInfoFirstName = config.userInfoFirstName
        userInfoLastName = config.userInfoLastName
        userInfoEmail = config.userInfoEmail
    }

    func toAppliedConfig() -> ExploreConfig {
        ExploreConfig(
            environment: environment,
            privateKey: privateKey,
            publicKey: publicKey,
            orderToken: orderToken,
            userToken: userToken,
            fraudId: fraudId,
            fraudProvidersJson: fraudProvidersJson,
            merchantName: merchantName,
            merchantCountryCode: merchantCountryCode,
            merchantCurrencyCode: merchantCurrencyCode,
            hidePayButton: hidePayButton,
            enableSplitPayment: enableSplitPayment,
            presentationMode: presentationMode,
            selectedWidget: selectedWidget,
            userInfoFirstName: userInfoFirstName,
            userInfoLastName: userInfoLastName,
            userInfoEmail: userInfoEmail
        )
    }
}
