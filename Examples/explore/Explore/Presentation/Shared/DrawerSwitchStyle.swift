import SwiftUI

/// Material-inspired switch style used in options rows.
struct DrawerSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                configuration.isOn.toggle()
            }
        } label: {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    configuration.isOn ? ExploreColors.brandBlue : Color(red: 0.75, green: 0.77, blue: 0.83)
                )
                .frame(width: 58, height: 34)
                .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .padding(3)
                        .shadow(color: Color.black.opacity(0.12), radius: 1.2, x: 0, y: 1)
                }
        }
        .buttonStyle(.plain)
    }
}
