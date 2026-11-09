import SwiftUI

struct CallbackUrlsSection: View {
    @Binding var callbackUrlSuccess: String
    @Binding var callbackUrlCanceled: String
    @Binding var callbackUrlPending: String

    var body: some View {
        DrawerCardSection(title: "Callback URLs (mercadopago_wallet)", icon: "link") {
            VStack(alignment: .leading, spacing: 10) {
                DrawerFieldTitle(title: "ON SUCCESS")
                ClearableTextField(
                    placeholder: "explore://success",
                    text: $callbackUrlSuccess,
                    accessibilityId: "sdktester.callbackUrlSuccessField"
                )

                DrawerFieldTitle(title: "ON CANCELED")
                ClearableTextField(
                    placeholder: "explore://canceled",
                    text: $callbackUrlCanceled,
                    accessibilityId: "sdktester.callbackUrlCanceledField"
                )

                DrawerFieldTitle(title: "ON PENDING")
                ClearableTextField(
                    placeholder: "explore://pending",
                    text: $callbackUrlPending,
                    accessibilityId: "sdktester.callbackUrlPendingField"
                )

                Button(action: {
                    let generated = IntegrationConfig.generateDefaultCallbackUrls()
                    callbackUrlSuccess = generated.success
                    callbackUrlCanceled = generated.canceled
                    callbackUrlPending = generated.pending
                }) {
                    Text("Generar")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(ExploreColors.brandBlue)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("sdktester.generateCallbackUrlsButton")
            }
        }
    }
}
