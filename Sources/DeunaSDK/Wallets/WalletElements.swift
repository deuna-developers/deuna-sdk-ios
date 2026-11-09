import Foundation

internal class WalletElements {

    private let environment: Environment
    private let publicApiKey: String
    private let requestedProvider: WalletProvider
    private let orderToken: String?
    private let userInfo: DeunaSDK.UserInfo?
    private let callbacks: ElementsCallbacks
    private let progress = DeunaProgressView()

    init(
        environment: Environment,
        publicApiKey: String,
        requestedProvider: WalletProvider,
        orderToken: String?,
        userInfo: DeunaSDK.UserInfo?,
        callbacks: ElementsCallbacks
    ) {
        self.environment = environment
        self.publicApiKey = publicApiKey
        self.requestedProvider = requestedProvider
        self.orderToken = orderToken
        self.userInfo = userInfo
        self.callbacks = callbacks
    }

    func run() {
        guard let cached = GetWalletsAvailable.cachedWallets else {
            dispatchError(code: "NOT_INITIALIZED", message: "Call getWalletsAvailable() before initElements().")
            return
        }
        guard cached.contains(requestedProvider) else {
            dispatchError(code: "WALLET_UNAVAILABLE", message: "\(requestedProvider.rawValue) is not available on this device.")
            return
        }
        guard let handler = WalletHandlerRegistry.get(requestedProvider) else {
            dispatchError(code: "UNSUPPORTED_WALLET", message: "\(requestedProvider.rawValue) has no registered handler.")
            return
        }

        DispatchQueue.global(qos: .background).async {
            self.progress.show()
            do {
                let fetchResult = try self.fetchCredentials()

                guard
                    let userToken = fetchResult.userToken, !userToken.isEmpty,
                    let userId = fetchResult.userId, !userId.isEmpty
                else {
                    self.progress.dismiss()
                    self.dispatchError(
                        code: "MISSING_USER_AUTH",
                        message: "userToken or userId is missing — cannot tokenize wallet payment."
                    )
                    return
                }

                guard let credentials = fetchResult.credentials[self.requestedProvider] else {
                    self.progress.dismiss()
                    self.dispatchError(code: "NO_CREDENTIALS", message: "No credentials found for \(self.requestedProvider.rawValue).")
                    return
                }

                self.progress.dismiss()
                handler.launch(credentials: credentials) { result in
                    switch result {
                    case .success(let rawData):
                        self.progress.show()
                        self.tokenize(rawData: rawData, userToken: userToken, userId: userId)
                    case .error(let code, let message):
                        self.dispatchError(code: code, message: message)
                    case .closed:
                        DispatchQueue.main.async { self.callbacks.onClosed?(.userAction) }
                    }
                }
            } catch {
                self.progress.dismiss()
                DeunaLogs.error("[wallets] WalletElements failed: \(error.localizedDescription)")
                self.dispatchError(code: "WALLET_ELEMENTS_FAILED", message: error.localizedDescription)
            }
        }
    }

    private func tokenize(rawData: [String: Any], userToken: String, userId: String) {
        guard let paymentData = rawData["paymentData"] as? [String: Any] else {
            progress.dismiss()
            dispatchError(code: "MISSING_PAYMENT_DATA", message: "Raw wallet data missing paymentData field.")
            return
        }

        DispatchQueue.global(qos: .background).async {
            do {
                let response = try TokenizeApplePayCard.tokenize(
                    environment: self.environment,
                    publicApiKey: self.publicApiKey,
                    userId: userId,
                    userToken: userToken,
                    paymentData: paymentData
                )

                self.progress.dismiss()
                if let nested = response["error"] as? [String: Any] {
                    let code = nested["code"] as? String ?? "TOKENIZATION_ERROR"
                    let message = nested["message"] as? String ?? "Card tokenization returned an error."
                    self.dispatchError(code: code, message: message)
                } else if let code = response["code"] as? String, !code.isEmpty,
                          response["message"] is String {
                    let message = response["message"] as? String ?? "Card tokenization returned an error."
                    self.dispatchError(code: code, message: message)
                } else {
                    DispatchQueue.main.async { self.callbacks.onSuccess?(response) }
                }
            } catch {
                self.progress.dismiss()
                DeunaLogs.error("[wallets] Apple Pay tokenization failed: \(error.localizedDescription)")
                self.dispatchError(code: "TOKENIZATION_REQUEST_FAILED", message: error.localizedDescription)
            }
        }
    }

    private func fetchCredentials() throws -> VaultResponseParser.FetchResult {
        guard let orderToken = orderToken else {
            return VaultResponseParser.FetchResult(
                credentials: GetWalletsAvailable.cachedCredentials,
                userToken: nil,
                userId: nil
            )
        }

        let encoded = orderToken.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? orderToken
        let url = "\(environment.config.elementsBaseUrl)/api/vault?orderToken=\(encoded)"
        let response = try DeunaHttpClient.post(
            url: url,
            headers: ["x-api-key": publicApiKey],
            body: VaultResponseParser.buildUserInfoBody(userInfo)
        )
        return VaultResponseParser.parseFetchResult(response)
    }

    private func dispatchError(code: String, message: String) {
        DeunaLogs.error("[wallets] \(code): \(message)")
        let error = ElementsError(
            type: .unknownError,
            metadata: ElementsError.ErrorMetadata(code: code, message: message)
        )
        DispatchQueue.main.async { self.callbacks.onError?(error) }
    }
}
