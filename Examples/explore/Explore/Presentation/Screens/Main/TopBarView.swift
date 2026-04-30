import SwiftUI

/// Reusable top app bar for the sample with drawer and optional embedded refresh actions.
struct TopBarView: View {
    let title: String
    let showRefresh: Bool
    let onOpenDrawer: () -> Void
    let onRefresh: () -> Void

    var body: some View {
        HStack {
            Button(action: onOpenDrawer) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .accessibilityIdentifier("sdktester.menuButton")

            Text(title)
                .font(.headline)
                .padding(.leading, 8)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            if showRefresh {
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .accessibilityIdentifier("sdktester.refreshButton")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color.white)
    }
}
