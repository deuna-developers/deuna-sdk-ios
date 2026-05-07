import DeunaSDK
import Foundation

/// Decides and executes widget launch flow for modal and embedded modes.
struct WidgetLaunchHandler {
    struct Input {
        let appliedConfig: ExploreConfig
        let draftConfig: ExploreDraftConfig
        let products: [ExploreProduct]
        let selectedProductIDs: Set<String>
        let useManualOrderTokenFlow: Bool
    }

    struct Output {
        let appliedConfig: ExploreConfig
        let draftConfig: ExploreDraftConfig
        let embeddedWidgetConfig: DeunaWidgetConfiguration?
        let isShowingEmbeddedScreen: Bool
        let modalStatusMessage: String?
    }

    private let paymentsRepository: PaymentsRepository

    init(paymentsRepository: PaymentsRepository) {
        self.paymentsRepository = paymentsRepository
    }

    func execute(input: Input) async -> Output {
        var nextApplied = input.appliedConfig
        var nextDraft = input.draftConfig

        if !input.useManualOrderTokenFlow {
            guard !input.selectedProductIDs.isEmpty else {
                return Output(
                    appliedConfig: input.appliedConfig,
                    draftConfig: input.draftConfig,
                    embeddedWidgetConfig: nil,
                    isShowingEmbeddedScreen: false,
                    modalStatusMessage: "Select at least one product to continue."
                )
            }

            let privateKey = input.appliedConfig.privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !privateKey.isEmpty else {
                return Output(
                    appliedConfig: input.appliedConfig,
                    draftConfig: input.draftConfig,
                    embeddedWidgetConfig: nil,
                    isShowingEmbeddedScreen: false,
                    modalStatusMessage: "Private Key is required to tokenize products."
                )
            }

            do {
                let selectedProducts = input.products.filter { input.selectedProductIDs.contains($0.id) }
                let result = try await paymentsRepository.createOrderToken(
                    environment: input.appliedConfig.environment,
                    privateKey: privateKey,
                    products: selectedProducts
                )
                nextApplied.orderToken = result.orderToken
                nextApplied.merchantName = result.merchantProfile.name
                nextApplied.merchantCountryCode = result.merchantProfile.countryCode
                nextApplied.merchantCurrencyCode = result.merchantProfile.currencyCode
                nextDraft = ExploreDraftConfig(from: nextApplied)
            } catch {
                return Output(
                    appliedConfig: input.appliedConfig,
                    draftConfig: input.draftConfig,
                    embeddedWidgetConfig: nil,
                    isShowingEmbeddedScreen: false,
                    modalStatusMessage: error.localizedDescription
                )
            }
        }

        if nextApplied.presentationMode == .modal {
            paymentsRepository.showModalWidget(config: nextApplied)
            return Output(
                appliedConfig: nextApplied,
                draftConfig: nextDraft,
                embeddedWidgetConfig: nil,
                isShowingEmbeddedScreen: false,
                modalStatusMessage: nil
            )
        }

        // Both .embedded and .autoResize use the same embedded widget config.
        // ModeContentView picks the right host screen based on presentationMode.
        return Output(
            appliedConfig: nextApplied,
            draftConfig: nextDraft,
            embeddedWidgetConfig: paymentsRepository.makeEmbeddedWidgetConfig(from: nextApplied),
            isShowingEmbeddedScreen: true,
            modalStatusMessage: nil
        )
    }
}
