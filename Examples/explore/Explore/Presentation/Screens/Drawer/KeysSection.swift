import SwiftUI

struct KeysSection: View {
    @Binding var publicKey: String
    @Binding var privateKey: String
    let keyErrorMessage: String?

    var body: some View {
        DrawerCardSection(title: "Keys", icon: "key.fill") {
            VStack(alignment: .leading, spacing: 10) {
                DrawerFieldTitle(title: "PUBLIC KEY")
                ClearableTextField(
                    placeholder: "pub_test••••••••••••",
                    text: $publicKey,
                    accessibilityId: "sdktester.publicKeyField"
                )

                DrawerFieldTitle(title: "PRIVATE KEY")
                ClearableTextField(
                    placeholder: "pk_test••••••••••••",
                    text: $privateKey,
                    accessibilityId: "sdktester.privateKeyField"
                )

                if let keyErrorMessage, !keyErrorMessage.isEmpty {
                    StatusBannerView(
                        message: keyErrorMessage,
                        color: Color.red.opacity(0.92),
                        accessibilityId: "sdktester.keysErrorBanner"
                    )
                }
            }
        }
    }
}
