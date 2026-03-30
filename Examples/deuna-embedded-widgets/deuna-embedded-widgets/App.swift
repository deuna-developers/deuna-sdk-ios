import SwiftUI
import DeunaSDK

@main
struct deuna_embedded_widgtesApp: App {
    var body: some Scene {
        WindowGroup {
            MainScreen(
                deunaSDK: DeunaSDK(
                    environment: .sandbox,
                    publicApiKey: "YOUR_PUBLIC_API_KEY"
                )
            )
        }
    }
}
