import Foundation

enum ValidationError: LocalizedError {
    case publicKeyRequired
    case invalidFraudProvidersJson

    var errorDescription: String? {
        switch self {
        case .publicKeyRequired:
            return "Public API Key is required."
        case .invalidFraudProvidersJson:
            return "Invalid fraud providers JSON."
        }
    }
}

enum FraudGenerationError: LocalizedError {
    case failed

    var errorDescription: String? {
        "Failed to generate FraudId (timeout or SDK callback error)."
    }
}
