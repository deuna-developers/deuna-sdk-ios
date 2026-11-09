import DeunaSDK
import SwiftUI

/// Full-height embedded widget host with an optional external "Pay Now" footer action.
struct EmbeddedScreen: View {
    let deunaSDK: DeunaSDK
    let embeddedWidgetConfig: DeunaWidgetConfiguration?
    let showPayNowButton: Bool
    let onPayNow: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            widgetContainer
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if showPayNowButton {
                Button(action: onPayNow) {
                    HStack(spacing: 8) {
                        Text("Pay Now")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryFooterButtonStyle())
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var widgetContainer: some View {
        ZStack {
            Color.white

            if let widgetConfig = embeddedWidgetConfig {
                DeunaWidget(deunaSDK: deunaSDK, configuration: widgetConfig)
            } else {
                Color.clear
            }
        }
    }
}

/// Reusable primary footer button style used by the embedded pay action.
private struct PrimaryFooterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(configuration.isPressed ? Color.blue.opacity(0.75) : Color.blue)
            .cornerRadius(24)
    }
}
