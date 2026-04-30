import SwiftUI

struct WidgetTypeSection: View {
    @Binding var selectedWidget: ExploreWidget

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Widget Type")
                .font(ExploreTypography.sectionTitle)
                .foregroundColor(.black.opacity(0.78))

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(ExploreWidget.allCases.enumerated()), id: \.element.id) { index, widget in
                    Button {
                        selectedWidget = widget
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: selectedWidget == widget ? "largecircle.fill.circle" : "circle")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(
                                    selectedWidget == widget ? ExploreColors.brandBlue : ExploreColors.labelGray)

                            Text(widget.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black.opacity(0.82))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, ExploreSpacing.cardPadding)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("sdktester.widgetOption.\(widget.rawValue)")
                    .accessibilityValue(selectedWidget == widget ? "selected" : "not_selected")

                    if index < ExploreWidget.allCases.count - 1 {
                        DrawerDivider()
                    }
                }
            }
            .background(ExploreColors.cardBackground)
            .cornerRadius(16)
        }
    }
}
