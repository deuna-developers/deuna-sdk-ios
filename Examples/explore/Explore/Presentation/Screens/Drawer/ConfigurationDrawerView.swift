import SwiftUI

/// High-level composition of the configuration drawer.
struct ConfigurationDrawerView: View {
    @Binding var draftConfig: ExploreDraftConfig
    @Binding var scrollToTopRequest: Int
    let isApplyingConfiguration: Bool
    let isGeneratingFraudId: Bool
    let keyErrorMessage: String?
    let fraudIdStatusMessage: String?
    let onCancel: () -> Void
    let onApply: () -> Void
    let onGenerateFraudId: () -> Void

    private let topAnchorId = "sdktester.drawer.top.anchor"

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: ExploreSpacing.sectionSpacing) {
                        Color.clear
                            .frame(height: 1)
                            .id(topAnchorId)

                        drawerHeader
                        environmentSection

                        KeysSection(
                            publicKey: $draftConfig.publicKey,
                            privateKey: $draftConfig.privateKey,
                            keyErrorMessage: keyErrorMessage
                        )

                        TokensSection(
                            orderToken: $draftConfig.orderToken,
                            userToken: $draftConfig.userToken
                        )

                        WidgetTypeSection(selectedWidget: $draftConfig.selectedWidget)

                        OptionsSection(
                            hidePayButton: $draftConfig.hidePayButton,
                            enableSplitPayment: $draftConfig.enableSplitPayment,
                            presentationMode: $draftConfig.presentationMode
                        )

                        FraudSection(
                            fraudProvidersJson: $draftConfig.fraudProvidersJson,
                            fraudId: $draftConfig.fraudId,
                            fraudIdStatusMessage: fraudIdStatusMessage,
                            isGeneratingFraudId: isGeneratingFraudId,
                            isApplyingConfiguration: isApplyingConfiguration,
                            onGenerateFraudId: onGenerateFraudId
                        )
                    }
                    .padding(.horizontal, ExploreSpacing.screenPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 22)
                }
                .accessibilityIdentifier("sdktester.drawer.content")
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: scrollToTopRequest) { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo(topAnchorId, anchor: .top)
                    }
                }
            }

            drawerFooter
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(ExploreColors.screenBackground)
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }

    private var drawerHeader: some View {
        HStack {
            Text("Configuration")
                .font(.system(size: 40, weight: .bold))
            Spacer()
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }

    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Environment")
                .font(ExploreTypography.sectionTitle)
                .foregroundColor(.black.opacity(0.78))

            SegmentedPillSelector(
                items: ExploreEnvironment.allCases,
                selectedId: draftConfig.environment.id,
                titleProvider: { $0.title },
                onSelect: { draftConfig.environment = $0 }
            )
        }
    }

    private var drawerFooter: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 1)

            HStack(spacing: 14) {
                Button(action: onCancel) {
                    Text("Cancelar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryActionButtonStyle())
                .accessibilityIdentifier("sdktester.cancelButton")
                .disabled(isApplyingConfiguration)

                Button(action: onApply) {
                    Text(isApplyingConfiguration ? "Generating..." : "Explorar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .accessibilityIdentifier("sdktester.applyButton")
                .disabled(isApplyingConfiguration)
            }
            .padding(.horizontal, ExploreSpacing.screenPadding)
            .padding(.vertical, 14)
        }
        .background(ExploreColors.screenBackground)
    }
}
