import Foundation

/// UI-only state holder that keeps visual flags separate from integration configuration.
struct ExploreUIState {
    var keyErrorMessage: String?
    var modalStatusMessage: String?
    var fraudIdStatusMessage: String?
    var isApplyingConfiguration = false
    var isLaunchingModalWidget = false
    var isGeneratingFraudId = false
    var isShowingEmbeddedScreen = false
    var useManualOrderTokenFlow = false
}
