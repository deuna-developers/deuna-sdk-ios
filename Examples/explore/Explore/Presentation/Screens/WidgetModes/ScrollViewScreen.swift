import DeunaSDK
import SwiftUI

/// Demonstrates DeunaWidget embedded inside a ScrollView.
/// The widget resizes automatically to match its WebView content height,
/// both when the content grows and when it shrinks.
struct ScrollViewScreen: View {
    let deunaSDK: DeunaSDK
    let widgetConfig: DeunaWidgetConfiguration?

    /// Tracks the WebView content height. Start with a sensible loading height
    /// so the widget occupies space while the page loads.
    @State private var widgetHeight: CGFloat = 300

    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(spacing: 0) {
                // Top container — 400 pt
                topContainer

                // DeunaWidget: resizes to WebView content height
                widgetContainer

                // Bottom container — 200 pt
                bottomContainer
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Subviews

    private var topContainer: some View {
        ZStack {
            Color.blue.opacity(0.15)
            VStack(spacing: 8) {
                Image(systemName: "cart.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text("Order Summary")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("400 pt — top container")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 400)
    }

    @ViewBuilder
    private var widgetContainer: some View {
        if let config = widgetConfig {
            DeunaWidget(
                deunaSDK: deunaSDK,
                configuration: config,
                height: $widgetHeight
            )
        } else {
            ZStack {
                Color(.secondarySystemBackground)
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Loading widget…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: widgetHeight)
        }
    }

    private var bottomContainer: some View {
        ZStack {
            Color.green.opacity(0.15)
            VStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                Text("Secure Checkout")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("200 pt — bottom container")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 200)
    }
}

#Preview {
    ScrollViewScreen(
        deunaSDK: DeunaSDK(environment: .sandbox, publicApiKey: "preview-key"),
        widgetConfig: nil
    )
}
