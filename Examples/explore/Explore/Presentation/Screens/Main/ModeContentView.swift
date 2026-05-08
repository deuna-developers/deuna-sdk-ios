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
    let generatedOrderToken: String?
    let modalStatusMessage: String?
    let isLaunchingModalWidget: Bool
    let isLaunchingWallets: Bool
    let isLaunchingFormularios: Bool
    let apmOptions: [ApmOption]
    let isLoadingApms: Bool
    let onPayNow: () -> Void
    let onClearOrder: () -> Void
    let onToggleProductSelection: (String) -> Void
    let onShowModalWidget: () -> Void
    let onShowWallets: () -> Void
    let onLoadApms: () -> Void
    let onShowFormularios: (ApmOption) -> Void

    var body: some View {
        if presentationMode == .embedded && isShowingEmbeddedScreen {
            EmbeddedScreen(
                deunaSDK: deunaSDK,
                embeddedWidgetConfig: embeddedWidgetConfig,
                showPayNowButton: showPayNowButton,
                onPayNow: onPayNow
            )
        } else {
            ModalScreen(
                products: products,
                selectedProductIDs: selectedProductIDs,
                useManualOrderTokenFlow: useManualOrderTokenFlow,
                generatedOrderToken: generatedOrderToken,
                modalStatusMessage: modalStatusMessage,
                isLaunchingModalWidget: isLaunchingModalWidget,
                isLaunchingWallets: isLaunchingWallets,
                isLaunchingFormularios: isLaunchingFormularios,
                apmOptions: apmOptions,
                isLoadingApms: isLoadingApms,
                onToggleProductSelection: onToggleProductSelection,
                onClearOrder: onClearOrder,
                onShowWidget: onShowModalWidget,
                onShowWallets: onShowWallets,
                onLoadApms: onLoadApms,
                onShowFormularios: onShowFormularios
            )
        }
    }
}
