import SwiftUI

struct OptionsSection: View {
    @Binding var hidePayButton: Bool
    @Binding var enableSplitPayment: Bool
    @Binding var presentationMode: ExplorePresentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Options")
                .font(ExploreTypography.sectionTitle)
                .foregroundColor(.black.opacity(0.78))

            VStack(spacing: 0) {
                DrawerOptionRow(title: "Hide Widget Pay Button") {
                    Toggle("", isOn: $hidePayButton)
                        .accessibilityIdentifier("sdktester.hidePayButtonToggle")
                        .labelsHidden()
                        .toggleStyle(DrawerSwitchStyle())
                }

                DrawerDivider()

                DrawerOptionRow(title: "Enable Split Payment") {
                    Toggle("", isOn: $enableSplitPayment)
                        .accessibilityIdentifier("sdktester.enableSplitPaymentToggle")
                        .labelsHidden()
                        .toggleStyle(DrawerSwitchStyle())
                }

                DrawerDivider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Presentation Mode")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black.opacity(0.82))

                    HStack(spacing: 0) {
                        ForEach(ExplorePresentationMode.allCases) { mode in
                            Button {
                                presentationMode = mode
                            } label: {
                                Text(mode.title)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(
                                        presentationMode == mode ? ExploreColors.brandBlue : ExploreColors.labelGray
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(presentationMode == mode ? Color.white : Color.clear)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("sdktester.presentationMode.\(mode.rawValue)")
                            .accessibilityValue(presentationMode == mode ? "selected" : "not_selected")
                        }
                    }
                    .padding(4)
                    .background(ExploreColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding(.horizontal, ExploreSpacing.cardPadding)
                .padding(.vertical, ExploreSpacing.cardPadding)
            }
            .background(ExploreColors.cardBackground)
            .cornerRadius(16)
        }
    }
}
