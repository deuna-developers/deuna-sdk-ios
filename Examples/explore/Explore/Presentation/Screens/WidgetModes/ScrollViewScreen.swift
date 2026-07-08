import DeunaSDK
import SwiftUI
import UIKit

/// Walks UP the UIView hierarchy to find the nearest UIScrollView parent.
/// Used to get a direct handle on the SwiftUI ScrollView's underlying UIScrollView.
private struct ScrollViewFinder: UIViewRepresentable {
    let onFound: (UIScrollView) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isHidden = true
        DispatchQueue.main.async { self.search(from: view) }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private func search(from view: UIView) {
        var parent = view.superview
        while let p = parent {
            if let sv = p as? UIScrollView {
                onFound(sv)
                return
            }
            parent = p.superview
        }
    }
}

/// Demonstrates DeunaWidget embedded inside a ScrollView.
/// The widget resizes automatically to match its WebView content height,
/// both when the content grows and when it shrinks.
struct AutoResizeScreen: View {
    let deunaSDK: DeunaSDK
    let widgetConfig: DeunaWidgetConfiguration?

    @State private var outerScrollView: UIScrollView?

    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(spacing: 0) {
                // Anchor to capture the underlying UIScrollView once the view is in hierarchy
                Color.clear.frame(height: 0)
                    .background(ScrollViewFinder { sv in outerScrollView = sv })

                // Top container — 400 pt
                topContainer

                // DeunaWidget: resizes to WebView content height.
                // When keyboard appears, outer ScrollView scrolls by the exact overlap
                // so the focused input stays visible without over-scrolling.
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
            DeunaWidget(deunaSDK: deunaSDK, configuration: config)
                .onScrollNeeded { overlap in
                    guard let sv = outerScrollView else { return }
                    let newOffset = CGPoint(x: 0, y: sv.contentOffset.y + overlap)
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                        sv.setContentOffset(newOffset, animated: false)
                    }
                }
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
            .frame(height: 300)
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
    AutoResizeScreen(
        deunaSDK: DeunaSDK(environment: .sandbox, publicApiKey: "preview-key"),
        widgetConfig: nil
    )
}
