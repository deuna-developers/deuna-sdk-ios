import DeunaSDK
import Foundation

/// Maps tester environments to DEUNA SDK runtime environments.
enum ExploreEnvironment: String, CaseIterable, Identifiable, Codable {
    case sandbox
    case development
    case staging

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sandbox: return "Sandbox"
        case .development: return "Develop"
        case .staging: return "Staging"
        }
    }

    var sdkEnvironment: Environment {
        switch self {
        case .sandbox: return .sandbox
        case .development: return .development
        case .staging: return .staging
        }
    }

    /// API Gateway base URL used by app-side order tokenization in the sample.
    var apiBaseURL: String {
        switch self {
        case .sandbox:
            return "https://api.sandbox.deuna.io"
        case .development:
            return "https://api.dev.deuna.io"
        case .staging:
            return "https://api.stg.deuna.io"
        }
    }
}
