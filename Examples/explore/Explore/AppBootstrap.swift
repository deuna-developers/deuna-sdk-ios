import Foundation

/// Resolves startup configuration from local defaults and process environment variables.
enum AppBootstrap {
    private struct BootstrapConfig {
        let environment: ExploreEnvironment
        let privateApiKey: String
        let publicApiKey: String
        let orderToken: String
        let userToken: String

        static let `default` = BootstrapConfig(
            environment: .sandbox,
            privateApiKey: "",
            publicApiKey: "",
            orderToken: "",
            userToken: ""
        )

        var hasPublicApiKey: Bool {
            !publicApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    static func initialConfig() -> ExploreConfig {
        var config = ExploreConfig.default
        let bootstrap = BootstrapConfig.default

        if bootstrap.hasPublicApiKey {
            config.environment = bootstrap.environment
            config.privateKey = bootstrap.privateApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
            config.publicKey = bootstrap.publicApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
            config.orderToken = bootstrap.orderToken
            config.userToken = bootstrap.userToken
            return config
        }

        let processEnvironment = ProcessInfo.processInfo.environment

        if let env = processEnvironment["DEUNA_ENV"]?.lowercased() {
            switch env {
            case "develop", "development":
                config.environment = .development
            case "staging":
                config.environment = .staging
            case "sandbox":
                config.environment = .sandbox
            default:
                break
            }
        }

        if let publicApiKey = processEnvironment["DEUNA_API_KEY"]?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !publicApiKey.isEmpty
        {
            config.publicKey = publicApiKey
        }

        if let privateApiKey = processEnvironment["DEUNA_PRIVATE_API_KEY"]?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !privateApiKey.isEmpty
        {
            config.privateKey = privateApiKey
        }

        return config
    }
}
