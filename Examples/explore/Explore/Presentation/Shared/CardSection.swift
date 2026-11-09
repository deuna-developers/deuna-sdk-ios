import SwiftUI

struct DrawerCardSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(ExploreColors.brandBlue)
                    .font(.system(size: 16, weight: .semibold))

                Text(title)
                    .font(ExploreTypography.sectionTitle)
                    .foregroundColor(.black.opacity(0.82))
            }

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, ExploreSpacing.cardPadding)
        .padding(.vertical, ExploreSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ExploreColors.cardBackground)
        .cornerRadius(16)
    }
}

struct DrawerFieldTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(ExploreTypography.fieldTitle)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DrawerDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.07))
            .frame(height: 1)
            .padding(.horizontal, ExploreSpacing.cardPadding)
    }
}

struct DrawerOptionRow<Accessory: View>: View {
    let title: String
    @ViewBuilder let accessory: () -> Accessory

    var body: some View {
        HStack {
            Text(title)
                .font(ExploreTypography.body)
                .foregroundColor(.black.opacity(0.82))
                .frame(maxWidth: .infinity, alignment: .leading)
            accessory()
        }
        .padding(.horizontal, ExploreSpacing.cardPadding)
        .padding(.vertical, ExploreSpacing.cardPadding)
    }
}
