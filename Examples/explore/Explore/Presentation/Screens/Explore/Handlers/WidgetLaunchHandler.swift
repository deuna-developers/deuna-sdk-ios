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

    /// Creates order token if needed but does NOT launch any widget.
    /// Use this when the caller controls which widget to open (e.g. Formularios).
    struct PrepareOutput {
        let appliedConfig: ExploreConfig
        let draftConfig: ExploreDraftConfig
        let modalStatusMessage: String?
    }

    private let paymentsRepository: PaymentsRepository

    init(paymentsRepository: PaymentsRepository) {
        self.paymentsRepository = paymentsRepository
    }

    func prepare(input: Input) async -> PrepareOutput {
        var nextApplied = input.appliedConfig
        var nextDraft = input.draftConfig

        if !input.useManualOrderTokenFlow {
            guard !input.selectedProductIDs.isEmpty else {
                return PrepareOutput(
                    appliedConfig: input.appliedConfig,
                    draftConfig: input.draftConfig,
                    modalStatusMessage: "Select at least one product to continue."
                )
            }

            let privateKey = input.appliedConfig.privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !privateKey.isEmpty else {
                return PrepareOutput(
                    appliedConfig: input.appliedConfig,
                    draftConfig: input.draftConfig,
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
                return PrepareOutput(
                    appliedConfig: input.appliedConfig,
                    draftConfig: input.draftConfig,
                    modalStatusMessage: error.localizedDescription
                )
            }
        }

        return PrepareOutput(appliedConfig: nextApplied, draftConfig: nextDraft, modalStatusMessage: nil)
    }

    func execute(input: Input) async -> Output {
        let prep = await prepare(input: input)
        guard prep.modalStatusMessage == nil else {
            return Output(
                appliedConfig: prep.appliedConfig,
                draftConfig: prep.draftConfig,
                embeddedWidgetConfig: nil,
                isShowingEmbeddedScreen: false,
                modalStatusMessage: prep.modalStatusMessage
            )
        }

        if prep.appliedConfig.presentationMode == .modal {
            paymentsRepository.showModalWidget(config: prep.appliedConfig)
            return Output(
                appliedConfig: prep.appliedConfig,
                draftConfig: prep.draftConfig,
                embeddedWidgetConfig: nil,
                isShowingEmbeddedScreen: false,
                modalStatusMessage: nil
            )
        }

        return Output(
            appliedConfig: prep.appliedConfig,
            draftConfig: prep.draftConfig,
            embeddedWidgetConfig: paymentsRepository.makeEmbeddedWidgetConfig(from: prep.appliedConfig),
            isShowingEmbeddedScreen: true,
            modalStatusMessage: nil
        )
    }
}
