import DeunaSDK
import SwiftUI

/// Root screen for the Explore app.
/// It composes the top bar, drawer, and modal/embedded content while delegating SDK logic to the coordinator.
struct MainContainerView: View {
    @StateObject private var coordinator: ExploreCoordinator
    @State private var isDrawerOpen = false
    @State private var drawerScrollToTopRequest = 0

    init(initialConfig: ExploreConfig = .default) {
        _coordinator = StateObject(wrappedValue: ExploreCoordinator(initialConfig: initialConfig))
    }

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            ZStack(alignment: .leading) {
                VStack(spacing: 0) {
                    TopBarView(
                        title: coordinator.appliedConfig.merchantName.isEmpty
                            ? "SDK Tester" : coordinator.appliedConfig.merchantName,
                        showRefresh: coordinator.appliedConfig.presentationMode == .embedded
                            && coordinator.isShowingEmbeddedScreen,
                        onOpenDrawer: openDrawer,
                        onRefresh: coordinator.refreshEmbedded
                    )
                    Divider()
                    ModeContentView(
                        presentationMode: coordinator.appliedConfig.presentationMode,
                        deunaSDK: coordinator.deunaSDK,
                        embeddedWidgetConfig: coordinator.embeddedWidgetConfig,
                        isShowingEmbeddedScreen: coordinator.isShowingEmbeddedScreen,
                        showPayNowButton: coordinator.appliedConfig.hidePayButton,
                        products: coordinator.products,
                        selectedProductIDs: coordinator.selectedProductIDs,
                        useManualOrderTokenFlow: coordinator.useManualOrderTokenFlow,
                        generatedOrderToken: coordinator.generatedOrderToken,
                        modalStatusMessage: coordinator.modalStatusMessage,
                        isLaunchingModalWidget: coordinator.isLaunchingModalWidget,
                        isLaunchingWallets: coordinator.isLaunchingWallets,
                        isLaunchingFormularios: coordinator.isLaunchingFormularios,
                        apmOptions: coordinator.apmOptions,
                        isLoadingApms: coordinator.isLoadingApms,
                        onPayNow: coordinator.submitEmbedded,
                        onClearOrder: coordinator.clearGeneratedOrder,
                        onToggleProductSelection: coordinator.toggleProductSelection,
                        onShowModalWidget: {
                            Task { await coordinator.showModalWidget() }
                        },
                        onShowWallets: {
                            Task { await coordinator.showWallets() }
                        },
                        onLoadApms: {
                            coordinator.loadApmOptions()
                        },
                        onShowFormularios: { apm in
                            Task { await coordinator.showFormularios(apm: apm) }
                        }
                    )
                }
                .background(Color(.systemGroupedBackground))
                .navigationDestination(for: ExploreRoute.self) { route in
                    ExploreRouteDestinationView(route: route)
                }

                if isDrawerOpen {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture { closeDrawer() }

                    ConfigurationDrawerView(
                        draftConfig: $coordinator.draftConfig,
                        scrollToTopRequest: $drawerScrollToTopRequest,
                        isApplyingConfiguration: coordinator.isApplyingConfiguration,
                        isGeneratingFraudId: coordinator.isGeneratingFraudId,
                        keyErrorMessage: coordinator.keyErrorMessage,
                        fraudIdStatusMessage: coordinator.fraudIdStatusMessage,
                        onCancel: {
                            coordinator.discardDraftChanges()
                            closeDrawer()
                        },
                        onApply: {
                            Task {
                                let didApply = await coordinator.applyConfiguration()
                                if didApply {
                                    closeDrawer()
                                } else if coordinator.keyErrorMessage != nil {
                                    drawerScrollToTopRequest += 1
                                }
                            }
                        },
                        onGenerateFraudId: {
                            Task { await coordinator.generateFraudIdForDrawer() }
                        }
                    )
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .leading))
                }
            }
            .animation(.easeInOut(duration: 0.22), value: isDrawerOpen)
        }
        .onAppear {
            coordinator.applyAndLaunchIfNeeded(config: coordinator.appliedConfig)
        }
    }

    private func openDrawer() {
        coordinator.draftConfig = ExploreDraftConfig(from: coordinator.appliedConfig)
        isDrawerOpen = true
    }

    private func closeDrawer() {
        isDrawerOpen = false
    }
}

#Preview {
    MainContainerView()
}
