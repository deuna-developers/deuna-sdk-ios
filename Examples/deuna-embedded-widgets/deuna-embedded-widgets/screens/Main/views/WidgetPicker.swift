import SwiftUI

enum WidgetToShow: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case paymentWidget
    case nextActionWidget
    case voucherWidget
    case checkoutWidget
    case vaultWidget
    case clickToPayWidget

    var label: String {
        switch self {
        case .paymentWidget:
            return "Payment Widget"
        case .nextActionWidget:
            return "Next Action Widget"
        case .voucherWidget:
            return "Voucher Widget"
        case .checkoutWidget:
            return "Checkout Widget"
        case .vaultWidget:
            return "Vault Widget"
        case .clickToPayWidget:
            return "Click to Pay"
        }
    }
}

struct WidgetPicker: View {
    @Binding var selectedWidget: WidgetToShow

    var body: some View {
        Picker("Selecciona el Widget", selection: $selectedWidget) {
            ForEach(WidgetToShow.allCases) { widgetType in
                Text(widgetType.label).tag(widgetType)
            }
        }
        .pickerStyle(.menu)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
