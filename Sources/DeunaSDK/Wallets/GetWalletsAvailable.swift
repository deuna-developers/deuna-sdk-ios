import Foundation

public struct GetWalletsAvailableParams {
    public let orderToken: String?
    public let userInfo: DeunaSDK.UserInfo?

    public init(orderToken: String? = nil, userInfo: DeunaSDK.UserInfo? = nil) {
        self.orderToken = orderToken
        self.userInfo = userInfo
    }
}

public extension DeunaSDK {
    func getWalletsAvailable(
        params: GetWalletsAvailableParams? = nil,
        callback: @escaping ([WalletProvider], WalletsError?) -> Void
    ) {
        GetWalletsAvailable(
            environment: configuration.environment,
            publicApiKey: configuration.publicApiKey,
            params: params,
            callback: callback
        ).run()
    }
}

internal class GetWalletsAvailable {

    static var cachedWallets: [WalletProvider]?
    static var cachedCredentials: [WalletProvider: WalletCredentials] = [:]

    private let environment: Environment
    private let publicApiKey: String
    private let params: GetWalletsAvailableParams?
    private let callback: ([WalletProvider], WalletsError?) -> Void

    init(
        environment: Environment,
        publicApiKey: String,
        params: GetWalletsAvailableParams?,
        callback: @escaping ([WalletProvider], WalletsError?) -> Void
    ) {
        self.environment = environment
        self.publicApiKey = publicApiKey
        self.params = params
        self.callback = callback
    }

    func run() {
        if let cached = GetWalletsAvailable.cachedWallets {
            DeunaLogs.info("[wallets] Returning cached wallets")
            callbackOnMain(cached, nil)
            return
        }

        DispatchQueue.global(qos: .background).async {
            do {
                let parsed = try self.fetchAndParse()
                let available = parsed.providers.filter {
                    self.isAvailableOnDevice($0)
                }
                GetWalletsAvailable.cachedWallets = available
                GetWalletsAvailable.cachedCredentials = parsed.credentials
                self.callbackOnMain(available, nil)
            } catch {
                DeunaLogs.error("[wallets] getWalletsAvailable failed: \(error.localizedDescription)")
                self.callbackOnMain([], WalletsError.fetchFailed(error.localizedDescription))
            }
        }
    }

    private func fetchAndParse() throws -> VaultResponseParser.ProvidersResult {
        var urlString = "\(environment.config.elementsBaseUrl)/api/vault"
        if let orderToken = params?.orderToken,
           let encoded = orderToken.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "?orderToken=\(encoded)"
        }

        let response = try DeunaHttpClient.post(
            url: urlString,
            headers: ["x-api-key": publicApiKey],
            body: VaultResponseParser.buildUserInfoBody(params?.userInfo)
        )
        return VaultResponseParser.parseProviders(response)
    }

    private func isAvailableOnDevice(_ provider: WalletProvider) -> Bool {
        return WalletHandlerRegistry.get(provider)?.isAvailableOnDevice() ?? false
    }

    private func callbackOnMain(_ wallets: [WalletProvider], _ error: WalletsError?) {
        DeunaLogs.info("[wallets] Available wallets: \(wallets.count)")
        if Thread.isMainThread {
            callback(wallets, error)
        } else {
            DispatchQueue.main.async { self.callback(wallets, error) }
        }
    }
}
