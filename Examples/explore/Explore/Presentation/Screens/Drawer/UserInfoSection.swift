import SwiftUI

struct UserInfoSection: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String

    var body: some View {
        DrawerCardSection(title: "User Info", icon: "person.fill") {
            VStack(alignment: .leading, spacing: 10) {
                DrawerFieldTitle(title: "FIRST NAME (OPTIONAL)")
                ClearableTextField(
                    placeholder: "John",
                    text: $firstName,
                    accessibilityId: "sdktester.userInfoFirstNameField"
                )
                DrawerFieldTitle(title: "LAST NAME (OPTIONAL)")
                ClearableTextField(
                    placeholder: "Doe",
                    text: $lastName,
                    accessibilityId: "sdktester.userInfoLastNameField"
                )
                DrawerFieldTitle(title: "EMAIL")
                ClearableTextField(
                    placeholder: "john@example.com",
                    text: $email,
                    accessibilityId: "sdktester.userInfoEmailField"
                )
            }
        }
    }
}
