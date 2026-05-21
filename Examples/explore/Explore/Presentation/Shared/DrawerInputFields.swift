import SwiftUI

struct ClearableTextField: View {
    let placeholder: String
    @Binding var text: String
    let accessibilityId: String

    var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier(accessibilityId)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
        }
        .drawerInputFieldStyle()
    }
}

struct ClearableTextEditor: View {
    let placeholder: String
    @Binding var text: String
    let accessibilityId: String
    let minHeight: CGFloat
    let maxHeight: CGFloat

    init(
        placeholder: String,
        text: Binding<String>,
        accessibilityId: String,
        minHeight: CGFloat = 88,
        maxHeight: CGFloat = 110
    ) {
        self.placeholder = placeholder
        self._text = text
        self.accessibilityId = accessibilityId
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 14))
                .frame(minHeight: minHeight, maxHeight: maxHeight)
                .padding(.trailing, 26)
                .accessibilityIdentifier(accessibilityId)

            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.8))
                    .padding(.top, 8)
                    .padding(.leading, 6)
            }

            if !text.isEmpty {
                HStack {
                    Spacer()
                    VStack {
                        Button(action: { text = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        Spacer()
                    }
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
            }
        }
        .drawerInputFieldStyle()
    }
}

extension View {
    fileprivate func drawerInputFieldStyle() -> some View {
        self
            .font(.system(size: 16, weight: .regular))
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.68))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(ExploreColors.cardBackground.opacity(0.2), lineWidth: 1)
            )
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
