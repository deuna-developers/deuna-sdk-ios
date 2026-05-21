import DeunaSDK
import Foundation

/// Central place for translating tester config into SDK widget init/config calls.
struct WidgetConfigBuilder {
    private let definitions = WidgetDefinitions()

    func makeEmbeddedConfiguration(
        from config: ExploreConfig,
        callbacks: WidgetCallbacksFactory
    ) -> DeunaWidgetConfiguration {
        switch config.selectedWidget {
        case .paymentWidget:
            return PaymentWidgetConfiguration(
                orderToken: config.orderToken,
                callbacks: callbacks.payment(),
                userToken: definitions.tokenOrNil(config.userToken),
                hidePayButton: config.hidePayButton,
                behavior: definitions.splitPaymentBehavior(enabled: config.enableSplitPayment)
            )
        case .checkoutWidget:
            return CheckoutWidgetConfiguration(
                orderToken: config.orderToken,
                callbacks: callbacks.checkout(),
                userToken: definitions.tokenOrNil(config.userToken),
                hidePayButton: config.hidePayButton
            )
        case .vaultWidget:
            return ElementsWidgetConfiguration(
                userToken: definitions.tokenOrNil(config.userToken),
                callbacks: callbacks.elements(),
                userInfo: definitions.fallbackUserInfoIfNeeded(config),
                orderToken: definitions.tokenOrNil(config.orderToken),
                hidePayButton: config.hidePayButton,
                behavior: definitions.splitPaymentBehavior(enabled: config.enableSplitPayment)
            )
        case .nextActionWidget:
            return NextActionWidgetConfiguration(
                orderToken: config.orderToken,
                callbacks: callbacks.nextAction()
            )
        case .voucherWidget:
            return VoucherWidgetConfiguration(
                orderToken: config.orderToken,
                callbacks: callbacks.voucher()
            )
        case .clickToPayWidget:
            return ElementsWidgetConfiguration(
                userToken: definitions.tokenOrNil(config.userToken),
                callbacks: callbacks.elements(),
                userInfo: definitions.fallbackUserInfoIfNeeded(config),
                types: [["name": ElementsWidget.clickToPay]],
                orderToken: definitions.tokenOrNil(config.orderToken),
                hidePayButton: config.hidePayButton
            )
        }
    }

    func launchModalWidget(
        using sdk: DeunaSDK,
        config: ExploreConfig,
        callbacks: WidgetCallbacksFactory
    ) {
        switch config.selectedWidget {
        case .paymentWidget:
            sdk.initPaymentWidget(
                orderToken: config.orderToken,
                callbacks: callbacks.payment(),
                userToken: definitions.tokenOrNil(config.userToken),
                behavior: definitions.splitPaymentBehavior(enabled: config.enableSplitPayment)
            )
        case .checkoutWidget:
            sdk.initCheckout(
                orderToken: config.orderToken,
                callbacks: callbacks.checkout(),
                userToken: definitions.tokenOrNil(config.userToken)
            )
        case .vaultWidget:
            sdk.initElements(
                userToken: definitions.tokenOrNil(config.userToken),
                callbacks: callbacks.elements(),
                userInfo: definitions.fallbackUserInfoIfNeeded(config),
                orderToken: definitions.tokenOrNil(config.orderToken),
                behavior: definitions.splitPaymentBehavior(enabled: config.enableSplitPayment)
            )
        case .nextActionWidget:
            sdk.initNextAction(orderToken: config.orderToken, callbacks: callbacks.nextAction())
        case .voucherWidget:
            sdk.initVoucher(orderToken: config.orderToken, callbacks: callbacks.voucher())
        case .clickToPayWidget:
            sdk.initElements(
                userToken: definitions.tokenOrNil(config.userToken),
                callbacks: callbacks.elements(),
                userInfo: definitions.fallbackUserInfoIfNeeded(config),
                types: [["name": ElementsWidget.clickToPay]],
                orderToken: definitions.tokenOrNil(config.orderToken)
            )
        }
    }

    func makeFormulariosEmbeddedConfig(
        using sdk: DeunaSDK,
        config: ExploreConfig,
        apm: ApmOption,
        callbacks: WidgetCallbacksFactory
    ) -> DeunaWidgetConfiguration {
        PaymentWidgetConfiguration(
            orderToken: config.orderToken,
            callbacks: callbacks.payment(),
            userToken: definitions.tokenOrNil(config.userToken),
            paymentMethods: [["paymentMethod": apm.paymentMethod, "processors": [apm.processor]]],
            hidePayButton: config.hidePayButton
        )
    }

    func launchFormulariosModal(
        using sdk: DeunaSDK,
        config: ExploreConfig,
        apm: ApmOption,
        callbacks: WidgetCallbacksFactory
    ) {
        sdk.initPaymentWidget(
            orderToken: config.orderToken,
            callbacks: callbacks.payment(),
            userToken: definitions.tokenOrNil(config.userToken),
            paymentMethods: [["paymentMethod": apm.paymentMethod, "processors": [apm.processor]]]
        )
    }
}
