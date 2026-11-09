import SwiftUI

@main
struct ExploreApp: App {
    var body: some Scene {
        WindowGroup {
            ExploreAppView(initialConfig: AppBootstrap.initialConfig())
                .preferredColorScheme(.light)
        }
    }
}
