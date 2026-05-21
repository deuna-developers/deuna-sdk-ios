import DeunaSDK
import Foundation

/// Repository implementation that delegates SDK operations to `DeunaSDKService`.
final class PaymentsRepositoryImpl: PaymentsRepository {
    private let sdkService: DeunaSDKService
    private let orderTokenService: OrderTokenService

    init(
        sdkService: DeunaSDKService,
        orderTokenService: OrderTokenService = OrderTokenService()
    ) {
        self.sdkService = sdkService
        self.orderTokenService = orderTokenService
    }

    var deunaSDK: DeunaSDK { sdkService.deunaSDK }

    func configureResultHandlers(
        onPaymentSuccess: @escaping ([String: Any]) -> Void,
        onSaveCardSuccess: @escaping ([String: Any]) -> Void
    ) {
        sdkService.configureResultHandlers(
            onPaymentSuccess: onPaymentSuccess,
            onSaveCardSuccess: onSaveCardSuccess
        )
    }

    func rebuild(environment: Environment, publicApiKey: String) {
        sdkService.rebuild(environment: environment, publicApiKey: publicApiKey)
    }

    func dispose() {
        sdkService.dispose()
    }

    func submitEmbedded() {
        sdkService.submitEmbedded()
    }

    func makeEmbeddedWidgetConfig(from config: ExploreConfig) -> DeunaWidgetConfiguration {
        sdkService.makeEmbeddedWidgetConfig(from: config)
    }

    func showModalWidget(config: ExploreConfig) {
        sdkService.showModalWidget(config: config)
    }

    func createOrderToken(
        environment: ExploreEnvironment,
        privateKey: String,
        products: [ExploreProduct]
    ) async throws -> OrderTokenResult {
        try await orderTokenService.createOrderToken(
            environment: environment,
            privateKey: privateKey,
            products: products
        )
    }

    func loadMerchantProfile(
        environment: ExploreEnvironment,
        privateKey: String
    ) async throws -> ExploreMerchantProfile {
        try await orderTokenService.loadMerchantProfile(
            environment: environment,
            privateKey: privateKey
        )
    }

    func generateFraudId(
        publicApiKey: String,
        environment: Environment,
        fraudProviders: Json,
        timeoutSeconds: UInt64
    ) async -> String? {
        await sdkService.generateFraudId(
            publicApiKey: publicApiKey,
            environment: environment,
            fraudProviders: fraudProviders,
            timeoutSeconds: timeoutSeconds
        )
    }
}
