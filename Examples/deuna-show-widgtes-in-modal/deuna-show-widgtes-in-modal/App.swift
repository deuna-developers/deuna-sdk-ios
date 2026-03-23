import SwiftUI
import DeunaSDK

/// Change this values to try the DEUNA SDK
struct Constants {
    static let DEUNA_ENV: DeunaEnvironment = .sandbox
    static let DEUNA_API_KEY: String = "DEUNA_PUBLIC_API_KEY"
}

@main
struct deuna_embedded_widgtesApp: App {
    var body: some Scene {
        WindowGroup {
            MainScreen(
                deunaSDK: DeunaSDK(
                    environment: getEnvironment() ?? Constants.DEUNA_ENV,
                    publicApiKey: getApiKey() ?? Constants.DEUNA_API_KEY
                )
            )
        }
    }
    
    /// For Integration testing get environment from process info
    private func getEnvironment() -> DeunaEnvironment? {
        let envString = ProcessInfo.processInfo.environment["DEUNA_ENV"]
        switch envString {
        case "development": return .development
        case "production": return .production
        case "staging": return .staging
        default: return nil
        }
    }
    
    /// For Integration testing get public api key from process info
    private func getApiKey() -> String? {
        return ProcessInfo.processInfo.environment["DEUNA_API_KEY"]
    }
}
