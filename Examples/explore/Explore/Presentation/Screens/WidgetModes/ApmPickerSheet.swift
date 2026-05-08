import SwiftUI

struct ApmPickerSheet: View {
    let options: [ApmOption]
    let isLoading: Bool
    let onSelect: (ApmOption) -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if options.isEmpty {
                    Text("No se pudieron cargar las opciones.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(options) { apm in
                        Button(action: { onSelect(apm) }) {
                            HStack(spacing: 12) {
                                Group {
                                    if let logoUrl = URL(string: apm.logo) {
                                        SvgImageView(url: logoUrl, size: 36)
                                    } else {
                                        Color(.systemGray5)
                                    }
                                }
                                .frame(width: 36, height: 36)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(apm.processor)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.primary)
                                    Text(apm.paymentMethod)
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Seleccionar Formulario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", action: onDismiss)
                }
            }
        }
    }
}
