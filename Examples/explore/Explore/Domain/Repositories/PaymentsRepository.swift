import DeunaSDK
import Foundation

/// Contract for payment flows in Explore:
/// merchant/profile retrieval, order tokenization and DEUNA SDK execution.
protocol PaymentsRepository {
    var deunaSDK: DeunaSDK { get }

    func configureResultHandlers(
        onPaymentSuccess: @escaping ([String: Any]) -> Void,
        onSaveCardSuccess: @escaping ([String: Any]) -> Void
    )
    func rebuild(environment: Environment, publicApiKey: String)
    func dispose()
    func submitEmbedded()
    func makeEmbeddedWidgetConfig(from config: ExploreConfig) -> DeunaWidgetConfiguration
    func showModalWidget(config: ExploreConfig)
    func createOrderToken(
        environment: ExploreEnvironment,
        privateKey: String,
        products: [ExploreProduct]
    ) async throws -> OrderTokenResult
    func loadMerchantProfile(
        environment: ExploreEnvironment,
        privateKey: String
    ) async throws -> ExploreMerchantProfile
    func generateFraudId(
        publicApiKey: String,
        environment: Environment,
        fraudProviders: Json,
        timeoutSeconds: UInt64
    ) async -> String?
}
