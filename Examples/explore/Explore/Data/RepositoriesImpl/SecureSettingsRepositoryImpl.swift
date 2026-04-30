import Foundation
import Security

/// Keychain-backed storage for sample app drawer configuration.
/// It keeps Explore settings across launches while preserving sensitive values securely.
final class ConfigStorage {
    static let shared = ConfigStorage()

    private enum EnvironmentKeys {
        static let disablePersistenceForTests = "DEUNA_DISABLE_CONFIG_PERSISTENCE"
    }

    private let service = "com.deuna.sdktester"
    private let account = "drawer.configuration"

    private init() {}

    func loadConfiguration(defaultValue: ExploreConfig) -> ExploreConfig {
        guard !isPersistenceDisabledForTests else {
            return defaultValue
        }

        guard let jsonString = readKeychain(account: account),
            let data = jsonString.data(using: .utf8)
        else {
            return defaultValue
        }

        do {
            return try JSONDecoder().decode(ExploreConfig.self, from: data)
        } catch {
            // If decoding fails, keep app functional with defaults.
            return defaultValue
        }
    }

    func saveConfiguration(_ config: ExploreConfig) {
        guard !isPersistenceDisabledForTests else {
            return
        }

        do {
            let data = try JSONEncoder().encode(config)
            let jsonString = String(decoding: data, as: UTF8.self)
            saveKeychain(value: jsonString, account: account)
        } catch {
            // Intentionally ignore encoding failures to avoid breaking UX flows.
        }
    }

    private func readKeychain(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
            let data = result as? Data,
            let value = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return value
    }

    private func saveKeychain(value: String, account: String) {
        let encoded = Data(value.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: encoded,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = encoded
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }

    /// Disables persisted config during integration tests to keep runs deterministic.
    private var isPersistenceDisabledForTests: Bool {
        let environment = ProcessInfo.processInfo.environment

        if environment["XCTestConfigurationFilePath"] != nil {
            return true
        }

        let value = environment[EnvironmentKeys.disablePersistenceForTests]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return value == "1" || value == "true" || value == "yes"
    }
}

/// Repository implementation for app configuration persistence.
final class SecureSettingsRepositoryImpl: SecureSettingsRepository {
    static let shared = SecureSettingsRepositoryImpl()

    private let storage: ConfigStorage

    init(storage: ConfigStorage = .shared) {
        self.storage = storage
    }

    func loadConfiguration(defaultValue: ExploreConfig) -> ExploreConfig {
        storage.loadConfiguration(defaultValue: defaultValue)
    }

    func saveConfiguration(_ config: ExploreConfig) {
        storage.saveConfiguration(config)
    }
}
