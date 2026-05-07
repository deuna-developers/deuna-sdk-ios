import DeunaSDK
import Foundation
import SwiftUI

/// Single UI entry-point used by `MainContainerView`.
/// It keeps presentation state minimal and delegates business flows to focused handlers.
final class ExploreCoordinator: ObservableObject {
    @Published var appliedConfig: ExploreConfig
    @Published var draftConfig: ExploreDraftConfig
    @Published var navigationPath = NavigationPath()
    @Published var embeddedWidgetConfig: DeunaWidgetConfiguration?
    @Published var products: [ExploreProduct] = []
    @Published var selectedProductIDs = Set<String>()
    @Published var isShowingEmbeddedScreen = false
    @Published var isApplyingConfiguration = false
    @Published var isLaunchingModalWidget = false
    @Published var keyErrorMessage: String?
    @Published var modalStatusMessage: String?
    @Published var fraudIdStatusMessage: String?
    @Published var isGeneratingFraudId = false
    @Published var useManualOrderTokenFlow = false

    var deunaSDK: DeunaSDK { paymentsRepository.deunaSDK }

    private let secureSettingsRepository: SecureSettingsRepository
    private let paymentsRepository: PaymentsRepository
    private let productsRepository: ProductsRepository
    private let configurationHandler: ConfigurationHandler
    private let widgetLaunchHandler: WidgetLaunchHandler
    private let fraudIdHandler: FraudIdHandler

    init(initialConfig: ExploreConfig = .default) {
        secureSettingsRepository = SecureSettingsRepositoryImpl.shared

        var hydratedConfig = secureSettingsRepository.loadConfiguration(defaultValue: initialConfig)
        if let forcedWidget = Self.forcedWidgetFromEnvironment() {
            hydratedConfig.selectedWidget = forcedWidget
        }

        appliedConfig = hydratedConfig
        draftConfig = ExploreDraftConfig(from: hydratedConfig)
        let productRepository = ProductsRepositoryImpl()
        productsRepository = productRepository
        products = productsRepository.buildProducts(currencyCode: hydratedConfig.merchantCurrencyCode)

        let sdkService = DeunaSDKService(
            environment: hydratedConfig.environment.sdkEnvironment,
            publicApiKey: hydratedConfig.publicKey,
            onPaymentMethodsEntered: {
                TestNotificationHelper.post(.paymentMethodsEntered)
            }
        )
        let paymentsRepository = PaymentsRepositoryImpl(sdkService: sdkService)
        self.paymentsRepository = paymentsRepository
        configurationHandler = ConfigurationHandler(
            paymentsRepository: paymentsRepository,
            productsRepository: productsRepository
        )
        widgetLaunchHandler = WidgetLaunchHandler(paymentsRepository: paymentsRepository)
        fraudIdHandler = FraudIdHandler(paymentsRepository: paymentsRepository)
        paymentsRepository.configureResultHandlers(
            onPaymentSuccess: { [weak self] payload in
                let router = ResultRouter { [weak self] route in
                    self?.navigationPath.append(route)
                }
                router.routePaymentSuccess(payload: payload)
            },
            onSaveCardSuccess: { [weak self] payload in
                let router = ResultRouter { [weak self] route in
                    self?.navigationPath.append(route)
                }
                router.routeSaveCardSuccess(payload: payload)
            }
        )
    }

    // MARK: - UI Actions

    /// Restores drawer draft values from the last applied configuration and clears UI feedback messages.
    func discardDraftChanges() {
        keyErrorMessage = nil
        modalStatusMessage = nil
        fraudIdStatusMessage = nil
        draftConfig = ExploreDraftConfig(from: appliedConfig)
    }

    /// Applies current drawer configuration, persists it, and rebuilds SDK runtime state.
    @MainActor
    func applyConfiguration() async -> Bool {
        keyErrorMessage = nil
        modalStatusMessage = nil
        fraudIdStatusMessage = nil
        isApplyingConfiguration = true
        defer { isApplyingConfiguration = false }

        do {
            let output = try await configurationHandler.execute(
                draftConfig: draftConfig,
                forcedWidget: Self.forcedWidgetFromEnvironment()
            )

            appliedConfig = output.appliedConfig
            draftConfig = output.draftConfig
            products = output.products
            useManualOrderTokenFlow = output.useManualOrderTokenFlow
            selectedProductIDs = []
            isShowingEmbeddedScreen = false
            embeddedWidgetConfig = nil
            secureSettingsRepository.saveConfiguration(appliedConfig)

            paymentsRepository.rebuild(
                environment: appliedConfig.environment.sdkEnvironment,
                publicApiKey: appliedConfig.publicKey
            )
            applyAndLaunchIfNeeded(config: appliedConfig)
            return true
        } catch {
            keyErrorMessage = error.localizedDescription
            return false
        }
    }

    /// Clears rendered widget content after configuration changes so next user action starts from a clean state.
    func applyAndLaunchIfNeeded(config: ExploreConfig) {
        embeddedWidgetConfig = nil
        isShowingEmbeddedScreen = false
    }

    /// Rebuilds SDK and recreates embedded widget configuration with the currently applied settings.
    func refreshEmbedded() {
        guard appliedConfig.presentationMode == .embedded || appliedConfig.presentationMode == .autoResize,
              isShowingEmbeddedScreen else { return }

        paymentsRepository.rebuild(
            environment: appliedConfig.environment.sdkEnvironment,
            publicApiKey: appliedConfig.publicKey
        )
        embeddedWidgetConfig = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.embeddedWidgetConfig = self.paymentsRepository.makeEmbeddedWidgetConfig(
                from: self.appliedConfig
            )
        }
    }

    /// Submits external pay action when embedded mode uses a custom app-side pay button.
    func submitEmbedded() {
        guard appliedConfig.presentationMode == .embedded else { return }
        paymentsRepository.submitEmbedded()
    }

    /// Launches the selected widget flow (modal or embedded) and updates UI state with the resulting output.
    @MainActor
    func showModalWidget() async {
        modalStatusMessage = nil
        isLaunchingModalWidget = true
        defer { isLaunchingModalWidget = false }

        let output = await widgetLaunchHandler.execute(
            input: .init(
                appliedConfig: appliedConfig,
                draftConfig: draftConfig,
                products: products,
                selectedProductIDs: selectedProductIDs,
                useManualOrderTokenFlow: useManualOrderTokenFlow
            )
        )
        appliedConfig = output.appliedConfig
        draftConfig = output.draftConfig
        embeddedWidgetConfig = output.embeddedWidgetConfig
        isShowingEmbeddedScreen = output.isShowingEmbeddedScreen
        modalStatusMessage = output.modalStatusMessage

        if output.modalStatusMessage == nil {
            secureSettingsRepository.saveConfiguration(appliedConfig)
        }
    }

    /// Toggles a product in the cart selection used for app-side order tokenization flow.
    func toggleProductSelection(productID: String) {
        if selectedProductIDs.contains(productID) {
            selectedProductIDs.remove(productID)
        } else {
            selectedProductIDs.insert(productID)
        }
    }

    /// Generates FraudId for drawer using configured providers JSON and updates status feedback.
    @MainActor
    func generateFraudIdForDrawer() async {
        fraudIdStatusMessage = nil
        isGeneratingFraudId = true
        defer { isGeneratingFraudId = false }

        do {
            let fraudId = try await fraudIdHandler.execute(
                publicApiKey: draftConfig.publicKey,
                environment: draftConfig.environment.sdkEnvironment,
                rawProvidersJson: draftConfig.fraudProvidersJson
            )
            draftConfig.fraudId = fraudId
            fraudIdStatusMessage = "FraudId generated."
        } catch {
            fraudIdStatusMessage = error.localizedDescription
        }
    }

    private static func forcedWidgetFromEnvironment() -> ExploreWidget? {
        guard
            let value = ProcessInfo.processInfo.environment["DEUNA_TEST_FORCE_WIDGET"]?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !value.isEmpty
        else {
            return nil
        }
        return ExploreWidget(rawValue: value)
    }
}
