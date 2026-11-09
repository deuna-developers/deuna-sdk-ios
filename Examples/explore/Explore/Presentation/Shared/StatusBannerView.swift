import SwiftUI

struct StatusBannerView: View {
    let message: String
    let color: Color
    let accessibilityId: String?

    var body: some View {
        Text(message)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color)
            )
            .accessibilityIdentifier(accessibilityId ?? "")
    }
}
