import DeunaSDK
import SwiftUI

/// Lightweight router that switches between embedded and modal sample content.
struct ModeContentView: View {
    let presentationMode: ExplorePresentationMode
    let deunaSDK: DeunaSDK
    let embeddedWidgetConfig: DeunaWidgetConfiguration?
    let isShowingEmbeddedScreen: Bool
    let showPayNowButton: Bool
    let products: [ExploreProduct]
    let selectedProductIDs: Set<String>
    let useManualOrderTokenFlow: Bool
    let modalStatusMessage: String?
    let isLaunchingModalWidget: Bool
    let onPayNow: () -> Void
    let onToggleProductSelection: (String) -> Void
    let onShowModalWidget: () -> Void

    var body: some View {
        if presentationMode == .embedded && isShowingEmbeddedScreen {
            EmbeddedScreen(
                deunaSDK: deunaSDK,
                embeddedWidgetConfig: embeddedWidgetConfig,
                showPayNowButton: showPayNowButton,
                onPayNow: onPayNow
            )
        } else if presentationMode == .scrollView && isShowingEmbeddedScreen {
            ScrollViewScreen(
                deunaSDK: deunaSDK,
                widgetConfig: embeddedWidgetConfig
            )
        } else {
            ModalScreen(
                products: products,
                selectedProductIDs: selectedProductIDs,
                useManualOrderTokenFlow: useManualOrderTokenFlow,
                modalStatusMessage: modalStatusMessage,
                isLaunchingModalWidget: isLaunchingModalWidget,
                onToggleProductSelection: onToggleProductSelection,
                onShowWidget: onShowModalWidget
            )
        }
    }
}
