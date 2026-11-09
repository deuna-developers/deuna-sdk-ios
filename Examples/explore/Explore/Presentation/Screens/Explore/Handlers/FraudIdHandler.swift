import DeunaSDK
import Foundation

/// Generates a FraudId from drawer input and validates user-provided providers JSON.
struct FraudIdHandler {
    private let paymentsRepository: PaymentsRepository

    init(paymentsRepository: PaymentsRepository) {
        self.paymentsRepository = paymentsRepository
    }

    func execute(
        publicApiKey: String,
        environment: Environment,
        rawProvidersJson: String
    ) async throws -> String {
        let trimmedPublicKey = publicApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPublicKey.isEmpty else {
            throw ValidationError.publicKeyRequired
        }

        let fraudProviders = try parseFraudProvidersJson(rawProvidersJson)
        let fraudId = await paymentsRepository.generateFraudId(
            publicApiKey: trimmedPublicKey,
            environment: environment,
            fraudProviders: fraudProviders,
            timeoutSeconds: 12
        )

        guard let fraudId, !fraudId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw FraudGenerationError.failed
        }

        return fraudId
    }

    private func parseFraudProvidersJson(_ rawJson: String) throws -> Json {
        let trimmed = rawJson.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let data = trimmed.data(using: .utf8) else {
            throw ValidationError.invalidFraudProvidersJson
        }

        guard
            let object = try? JSONSerialization.jsonObject(with: data, options: []),
            let json = object as? Json
        else {
            throw ValidationError.invalidFraudProvidersJson
        }

        return json
    }
}
