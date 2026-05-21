import SwiftUI

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ExploreTypography.cta)
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .background(
                configuration.isPressed ? ExploreColors.brandBlue.opacity(0.82) : ExploreColors.brandBlue
            )
            .cornerRadius(28)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ExploreTypography.cta)
            .foregroundColor(.black.opacity(0.82))
            .padding(.vertical, 14)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
            )
            .cornerRadius(28)
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}
