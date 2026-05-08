import DeunaSDK
import Foundation

/// Single façade that contains all direct DEUNA SDK calls used by the Explore sample.
/// Integrators can read this file first to understand SDK lifecycle and widget execution.
final class DeunaSDKService {
    private var sdk: DeunaSDK
    private let useMainThread = true
    private let configBuilder = WidgetConfigBuilder()
    private var onPaymentSuccess: ([String: Any]) -> Void = { _ in }
    private var onSaveCardSuccess: ([String: Any]) -> Void = { _ in }
    private let onPaymentMethodsEntered: () -> Void

    init(
        environment: Environment,
        publicApiKey: String,
        onPaymentMethodsEntered: @escaping () -> Void
    ) {
        self.onPaymentMethodsEntered = onPaymentMethodsEntered
        sdk = DeunaSDK(
            environment: environment,
            publicApiKey: publicApiKey,
            useMainThread: useMainThread
        )
    }

    func configureResultHandlers(
        onPaymentSuccess: @escaping ([String: Any]) -> Void,
        onSaveCardSuccess: @escaping ([String: Any]) -> Void
    ) {
        self.onPaymentSuccess = onPaymentSuccess
        self.onSaveCardSuccess = onSaveCardSuccess
    }

    var deunaSDK: DeunaSDK { sdk }

    func rebuild(environment: Environment, publicApiKey: String) {
        executeOnMain { [weak self] in
            guard let self else { return }
            sdk.dispose()
            sdk = DeunaSDK(
                environment: environment,
                publicApiKey: publicApiKey,
                useMainThread: useMainThread
            )
        }
    }

    func dispose() {
        executeOnMain { [weak self] in
            self?.sdk.dispose()
        }
    }

    func submitEmbedded() {
        executeOnMain { [weak self] in
            self?.sdk.submit { result in
                print("Submit result: \(result.status.rawValue)")
            }
        }
    }

    func makeEmbeddedWidgetConfig(from config: ExploreConfig) -> DeunaWidgetConfiguration {
        configBuilder.makeEmbeddedConfiguration(
            from: config,
            callbacks: makeCallbacksFactory()
        )
    }

    func showModalWidget(config: ExploreConfig) {
        executeOnMain { [weak self] in
            guard let self else { return }
            configBuilder.launchModalWidget(
                using: sdk,
                config: config,
                callbacks: makeCallbacksFactory()
            )
        }
    }

    func makeFormulariosEmbeddedConfig(config: ExploreConfig, apm: ApmOption) -> DeunaWidgetConfiguration {
        configBuilder.makeFormulariosEmbeddedConfig(
            using: sdk,
            config: config,
            apm: apm,
            callbacks: makeCallbacksFactory()
        )
    }

    func showFormulariosModal(config: ExploreConfig, apm: ApmOption) {
        executeOnMain { [weak self] in
            guard let self else { return }
            configBuilder.launchFormulariosModal(
                using: sdk,
                config: config,
                apm: apm,
                callbacks: makeCallbacksFactory()
            )
        }
    }

    func generateFraudId(
        publicApiKey: String,
        environment: Environment,
        fraudProviders: Json,
        timeoutSeconds: UInt64
    ) async -> String? {
        let fraudSDK = DeunaSDK(
            environment: environment,
            publicApiKey: publicApiKey
        )

        return await withCheckedContinuation { continuation in
            let lock = NSLock()
            var didResolve = false

            func resolveOnce(_ value: String?) {
                lock.lock()
                defer { lock.unlock() }
                guard !didResolve else { return }
                didResolve = true
                continuation.resume(returning: value)
            }

            fraudSDK.generateFraudId(params: fraudProviders) { generatedFraudId in
                resolveOnce(generatedFraudId)
            }

            Task {
                try? await Task.sleep(nanoseconds: timeoutSeconds * 1_000_000_000)
                resolveOnce(nil)
            }
        }
    }

    private func makeCallbacksFactory() -> WidgetCallbacksFactory {
        WidgetCallbacksFactory(
            onPaymentSuccess: { [weak self] payload in
                guard let self else { return }
                executeOnMain {
                    self.sdk.close {
                        self.onPaymentSuccess(payload)
                    }
                }
            },
            onSaveCardSuccess: { [weak self] payload in
                guard let self else { return }
                executeOnMain {
                    self.sdk.close {
                        self.onSaveCardSuccess(payload)
                    }
                }
            },
            onPaymentMethodsEntered: onPaymentMethodsEntered
        )
    }

    private func executeOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}
