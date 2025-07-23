import DeunaSDK
import SwiftUI

struct DeunaButton: View {
    let label: String
    var color: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(
            action: action
        ) {
            Text(label)
                .foregroundColor(Color.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
        }
        .background(color ?? Color.blue)
        .cornerRadius(10)
    }
}
