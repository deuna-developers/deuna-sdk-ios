import SwiftUI

struct TextInput: View {
    @Binding var text: String
    let label: String

    var body: some View {
        TextField(text: $text) {
            Text(label)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10).background(Color.white)
        .cornerRadius(10)
    }
}
