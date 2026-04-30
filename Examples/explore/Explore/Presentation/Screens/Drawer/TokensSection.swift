import SwiftUI

struct TokensSection: View {
    @Binding var orderToken: String
    @Binding var userToken: String

    var body: some View {
        DrawerCardSection(title: "Tokens", icon: "number.circle.fill") {
            VStack(alignment: .leading, spacing: 10) {
                DrawerFieldTitle(title: "ORDER TOKEN (OPTIONAL)")
                ClearableTextField(
                    placeholder: "order token",
                    text: $orderToken,
                    accessibilityId: "sdktester.orderTokenField"
                )

                DrawerFieldTitle(title: "USER TOKEN (OPTIONAL)")
                ClearableTextEditor(
                    placeholder: "user token",
                    text: $userToken,
                    accessibilityId: "sdktester.userTokenField"
                )
            }
        }
    }
}
