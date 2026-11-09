import Foundation

/// Contract for secure persistence of Explore configuration.
protocol SecureSettingsRepository {
    func loadConfiguration(defaultValue: ExploreConfig) -> ExploreConfig
    func saveConfiguration(_ config: ExploreConfig)
}
