import SwiftUI

private let navyBlue = Color(red: 0.106, green: 0.169, blue: 0.431)
private let mediumBlue = Color(red: 0.145, green: 0.388, blue: 0.922)
private let lightBlue = Color(red: 0.231, green: 0.510, blue: 0.965)
private let accentBlue = Color(red: 0.078, green: 0.478, blue: 0.910)

struct ModalScreen: View {
    let products: [ExploreProduct]
    let selectedProductIDs: Set<String>
    let useManualOrderTokenFlow: Bool
    let generatedOrderToken: String?
    let modalStatusMessage: String?
    let isLaunchingModalWidget: Bool
    let isLaunchingWallets: Bool
    let isLaunchingFormularios: Bool
    let apmOptions: [ApmOption]
    let isLoadingApms: Bool
    let onToggleProductSelection: (String) -> Void
    let onClearOrder: () -> Void
    let onShowWidget: () -> Void
    let onShowWallets: () -> Void
    let onLoadApms: () -> Void
    let onShowFormularios: (ApmOption) -> Void

    @State private var showApmPicker = false

    private var selectedProducts: [ExploreProduct] {
        products.filter { selectedProductIDs.contains($0.id) }
    }
    private var selectedTotalCents: Int { selectedProducts.reduce(0) { $0 + $1.priceInCents } }
    private var totalForManualFlowCents: Int { products.reduce(0) { $0 + $1.priceInCents } }
    private var currencySymbol: String { products.first?.currencySymbol ?? "$" }
    private var fractionDigits: Int { products.first?.fractionDigits ?? 2 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if useManualOrderTokenFlow {
                    manualCheckoutPreview
                } else if let token = generatedOrderToken {
                    orderCreatedCard(token: token)
                } else {
                    productCatalog
                }

                if let msg = modalStatusMessage, !msg.isEmpty {
                    Text(msg)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.red.opacity(0.9)))
                        .padding(.horizontal, 16)
                }

                VStack(spacing: 12) {
                    actionButton(
                        title: isLaunchingModalWidget ? "Preparing..." : "Show Widget",
                        color: navyBlue,
                        disabled: isLaunchingModalWidget,
                        id: "sdktester.showWidgetButton",
                        action: onShowWidget
                    )
                    actionButton(
                        title: isLaunchingWallets ? "Preparing..." : "Wallets",
                        color: mediumBlue,
                        disabled: isLaunchingWallets,
                        id: "sdktester.showWalletsButton",
                        action: onShowWallets
                    )
                    actionButton(
                        title: isLaunchingFormularios ? "Preparando..." : "Formularios",
                        color: lightBlue,
                        disabled: isLaunchingFormularios,
                        id: "sdktester.showFormulariosButton",
                        action: { onLoadApms(); showApmPicker = true }
                    )
                    .sheet(isPresented: $showApmPicker) {
                        ApmPickerSheet(
                            options: apmOptions,
                            isLoading: isLoadingApms,
                            onSelect: { apm in showApmPicker = false; onShowFormularios(apm) },
                            onDismiss: { showApmPicker = false }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func actionButton(title: String, color: Color, disabled: Bool, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(color)
                .cornerRadius(10)
        }
        .disabled(disabled)
        .opacity(disabled ? 0.85 : 1)
        .accessibilityIdentifier(id)
    }

    // MARK: - Product Catalog

    private var productCatalog: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Available Products")
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 16)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(products) { product in
                    productCard(for: product)
                }
            }
            .padding(.horizontal, 16)

            cartSummaryCard
                .padding(.horizontal, 16)
        }
    }

    private func productCard(for product: ExploreProduct) -> some View {
        let isSelected = selectedProductIDs.contains(product.id)
        return VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.image)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Color(.systemGray5)
                default:
                    Color(.systemGray6).overlay(ProgressView())
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .topLeading) {
                Text(ExploreProductCatalog.formatPrice(
                    cents: product.priceInCents,
                    fractionDigits: product.fractionDigits,
                    currencySymbol: product.currencySymbol
                ))
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .padding(6)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color(red: 0.086, green: 0.639, blue: 0.29))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .padding(6)
                }
            }

            Text(product.name)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)

            if isSelected {
                Button(action: { onToggleProductSelection(product.id) }) {
                    Text("Remove")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(accentBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(accentBlue, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("sdktester.product.\(product.id)")
            } else {
                Button(action: { onToggleProductSelection(product.id) }) {
                    Text("Add")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(accentBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("sdktester.product.\(product.id)")
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? accentBlue.opacity(0.6) : Color.clear, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var cartSummaryCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cart (\(selectedProducts.count))")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("\(selectedProducts.count) Items Selected")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 10)

            Divider()

            Group {
                HStack {
                    Text("Subtotal").font(.system(size: 13))
                    Spacer()
                    Text(ExploreProductCatalog.formatPrice(cents: selectedTotalCents, fractionDigits: fractionDigits, currencySymbol: currencySymbol))
                        .font(.system(size: 13))
                }
                .padding(.vertical, 6)

            }

            Divider()

            HStack {
                Text("Total").font(.system(size: 15, weight: .bold))
                Spacer()
                Text(ExploreProductCatalog.formatPrice(cents: selectedTotalCents, fractionDigits: fractionDigits, currencySymbol: currencySymbol))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(accentBlue)
            }
            .padding(.top, 10)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Order Created Card

    private func orderCreatedCard(token: String) -> some View {
        let sel = products.filter { selectedProductIDs.contains($0.id) }
        let total = sel.reduce(0) { $0 + $1.priceInCents }
        let shortToken = token.count > 20 ? String(token.prefix(20)) + "…" : token
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Order Created").font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(action: onClearOrder) {
                    Image(systemName: "xmark").font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
                }
            }
            Divider()
            HStack { Text("Token").font(.system(size: 13)); Spacer(); Text(shortToken).font(.system(size: 13, weight: .medium)) }
            HStack { Text("Items").font(.system(size: 13)); Spacer(); Text("\(sel.count)").font(.system(size: 13, weight: .medium)) }
            Divider()
            HStack {
                Text("Total").font(.system(size: 15, weight: .bold))
                Spacer()
                Text(ExploreProductCatalog.formatPrice(cents: total, fractionDigits: fractionDigits, currencySymbol: currencySymbol))
                    .font(.system(size: 16, weight: .bold)).foregroundStyle(accentBlue)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(accentBlue.opacity(0.4), lineWidth: 1.5))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
    }

    // MARK: - Manual Checkout Preview

    private var manualCheckoutPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Checkout").font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(action: onClearOrder) {
                    Image(systemName: "xmark").font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
                }
            }
            Divider()
            HStack { Text("Items").font(.system(size: 13)); Spacer(); Text("\(products.count)").font(.system(size: 13, weight: .medium)) }
            Divider()
            HStack {
                Text("Total").font(.system(size: 15, weight: .bold))
                Spacer()
                Text(ExploreProductCatalog.formatPrice(cents: totalForManualFlowCents, fractionDigits: fractionDigits, currencySymbol: currencySymbol))
                    .font(.system(size: 16, weight: .bold)).foregroundStyle(accentBlue)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
    }
}
