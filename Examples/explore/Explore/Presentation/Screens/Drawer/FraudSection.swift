import SwiftUI
import UIKit

struct FraudSection: View {
    @Binding var fraudProvidersJson: String
    @Binding var fraudId: String
    let fraudIdStatusMessage: String?
    let isGeneratingFraudId: Bool
    let isApplyingConfiguration: Bool
    let onGenerateFraudId: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DrawerFieldTitle(title: "FRAUD PROVIDERS JSON")
            ClearableTextEditor(
                placeholder: "{\n  \"RISKIFIED\": { \"storeDomain\": \"yourstore.com\" }\n}",
                text: $fraudProvidersJson,
                accessibilityId: "sdktester.fraudProvidersJsonField",
                minHeight: 120,
                maxHeight: 170
            )

            HStack(spacing: 8) {
                DrawerFieldTitle(title: "FRAUD ID")
                Spacer()
                HStack(spacing: 10) {
                    Button(action: {
                        UIPasteboard.general.string = fraudId
                    }) {
                        Text("Copy")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(ExploreColors.brandBlue)
                    }
                    .buttonStyle(.plain)
                    .disabled(fraudId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(fraudId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                    .accessibilityIdentifier("sdktester.copyFraudIdButton")

                    Button(action: onGenerateFraudId) {
                        Text(isGeneratingFraudId ? "Generando..." : "Generar")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(ExploreColors.brandBlue)
                    }
                    .buttonStyle(.plain)
                    .disabled(isGeneratingFraudId || isApplyingConfiguration)
                    .accessibilityIdentifier("sdktester.generateFraudIdButton")
                }
            }

            ClearableTextEditor(
                placeholder: "fraud id",
                text: $fraudId,
                accessibilityId: "sdktester.fraudIdField"
            )

            if let fraudIdStatusMessage, !fraudIdStatusMessage.isEmpty {
                Text(fraudIdStatusMessage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(
                        (fraudIdStatusMessage.lowercased().contains("failed")
                            || fraudIdStatusMessage.lowercased().contains("invalid")
                            || fraudIdStatusMessage.lowercased().contains("error")) ? .red : .green
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, ExploreSpacing.cardPadding)
        .padding(.vertical, ExploreSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ExploreColors.cardBackground)
        .cornerRadius(16)
    }
}
