import SwiftUI

struct DomainSection: View {
    @Binding var domain: String

    var body: some View {
        DrawerCardSection(title: "Domain", icon: "network") {
            VStack(alignment: .leading, spacing: 10) {
                DrawerFieldTitle(title: "DOMAIN (OPTIONAL)")
                ClearableTextField(
                    placeholder: "https://custom.domain.com",
                    text: $domain,
                    accessibilityId: "sdktester.domainField"
                )
            }
        }
    }
}
