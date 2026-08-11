import SwiftUI

/// Root app view used by the entry point.
struct ExploreAppView: View {
    let initialConfig: ExploreConfig

    var body: some View {
        MainContainerView(initialConfig: initialConfig)
    }
}
