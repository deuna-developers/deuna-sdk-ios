import Foundation

/// Applies drawer draft data into a validated `ExploreConfig` and hydrates merchant/order data when needed.
struct ConfigurationHandler {
    struct Output {
        let appliedConfig: ExploreConfig
        let draftConfig: ExploreDraftConfig
        let products: [ExploreProduct]
        let useManualOrderTokenFlow: Bool
    }

    private let paymentsRepository: PaymentsRepository
    private let productsRepository: ProductsRepository

    init(
        paymentsRepository: PaymentsRepository,
        productsRepository: ProductsRepository
    ) {
        self.paymentsRepository = paymentsRepository
        self.productsRepository = productsRepository
    }

    func execute(
        draftConfig: ExploreDraftConfig,
        forcedWidget: ExploreWidget?
    ) async throws -> Output {
        var nextConfig = draftConfig.toAppliedConfig()
        if let forcedWidget {
            nextConfig.selectedWidget = forcedWidget
        }

        if nextConfig.publicKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.publicKeyRequired
        }

        let privateKey = nextConfig.privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasManualOrderToken = !nextConfig.orderToken.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        // If an order token is already provided, we must always respect manual flow
        // (both modal and embedded) and avoid re-tokenizing products.
        let useManualFlow = hasManualOrderToken

        let shouldGenerateEmbeddedOrderToken =
            nextConfig.presentationMode == .embedded && !hasManualOrderToken && !privateKey.isEmpty

        if shouldGenerateEmbeddedOrderToken {
            let result = try await paymentsRepository.createOrderToken(
                environment: nextConfig.environment,
                privateKey: privateKey,
                products: productsRepository.buildProducts(currencyCode: nextConfig.merchantCurrencyCode)
            )
            nextConfig.orderToken = result.orderToken
            nextConfig.merchantName = result.merchantProfile.name
            nextConfig.merchantCountryCode = result.merchantProfile.countryCode
            nextConfig.merchantCurrencyCode = result.merchantProfile.currencyCode
        } else if !privateKey.isEmpty {
            let profile = try await paymentsRepository.loadMerchantProfile(
                environment: nextConfig.environment,
                privateKey: privateKey
            )
            nextConfig.merchantName = profile.name
            nextConfig.merchantCountryCode = profile.countryCode
            nextConfig.merchantCurrencyCode = profile.currencyCode
        }

        return Output(
            appliedConfig: nextConfig,
            draftConfig: ExploreDraftConfig(from: nextConfig),
            products: productsRepository.buildProducts(currencyCode: nextConfig.merchantCurrencyCode),
            useManualOrderTokenFlow: useManualFlow
        )
    }
}
