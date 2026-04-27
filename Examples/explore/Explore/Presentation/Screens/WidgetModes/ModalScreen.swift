import SwiftUI

/// Modal mode content:
/// - If order token is manual, shows a checkout-like summary.
/// - Otherwise shows a product grid where items can be added to a cart.
struct ModalScreen: View {
    let products: [ExploreProduct]
    let selectedProductIDs: Set<String>
    let useManualOrderTokenFlow: Bool
    let modalStatusMessage: String?
    let isLaunchingModalWidget: Bool
    let onToggleProductSelection: (String) -> Void
    let onShowWidget: () -> Void

    private var selectedProducts: [ExploreProduct] {
        products.filter { selectedProductIDs.contains($0.id) }
    }

    private var selectedTotalCents: Int {
        selectedProducts.reduce(0) { $0 + $1.priceInCents }
    }

    private var totalForManualFlowCents: Int {
        products.reduce(0) { $0 + $1.priceInCents }
    }

    private var currencySymbol: String {
        products.first?.currencySymbol ?? "$"
    }

    private var fractionDigits: Int {
        products.first?.fractionDigits ?? 2
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if useManualOrderTokenFlow {
                    manualCheckoutPreview
                } else {
                    productCatalog
                }

                if let modalStatusMessage, !modalStatusMessage.isEmpty {
                    Text(modalStatusMessage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.red.opacity(0.9))
                        )
                        .padding(.horizontal, 16)
                }

                Button(action: onShowWidget) {
                    Text(isLaunchingModalWidget ? "Preparing..." : "Show Widget")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(24)
                }
                .disabled(isLaunchingModalWidget)
                .opacity(isLaunchingModalWidget ? 0.85 : 1)
                .accessibilityIdentifier("sdktester.showWidgetButton")
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var manualCheckoutPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Checkout")
                .font(.system(size: 16, weight: .semibold))

            HStack {
                Text("Items")
                Spacer()
                Text("\(products.count)")
            }
            .font(.system(size: 14, weight: .medium))

            HStack {
                Text("Total")
                Spacer()
                Text(
                    ExploreProductCatalog.formatPrice(
                        cents: totalForManualFlowCents,
                        fractionDigits: fractionDigits,
                        currencySymbol: currencySymbol
                    ))
            }
            .font(.system(size: 16, weight: .bold))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }

    private var productCatalog: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Products")
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 16)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ], spacing: 12
            ) {
                ForEach(products) { product in
                    productCard(for: product)
                }
            }
            .padding(.horizontal, 16)

            HStack {
                Text("Cart (\(selectedProducts.count))")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Text(
                    ExploreProductCatalog.formatPrice(
                        cents: selectedTotalCents,
                        fractionDigits: fractionDigits,
                        currencySymbol: currencySymbol
                    )
                )
                .font(.system(size: 16, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)
        }
    }

    private func productCard(for product: ExploreProduct) -> some View {
        let isSelected = selectedProductIDs.contains(product.id)
        return VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "bag.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 34, height: 34)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(product.name)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)

            Text(
                ExploreProductCatalog.formatPrice(
                    cents: product.priceInCents,
                    fractionDigits: product.fractionDigits,
                    currencySymbol: product.currencySymbol
                )
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)

            Button(action: { onToggleProductSelection(product.id) }) {
                Text(isSelected ? "Added" : "Add")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.blue : Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(isSelected ? Color.blue.opacity(0.12) : Color.blue)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sdktester.product.\(product.id)")
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? Color.blue.opacity(0.6) : Color.clear, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
