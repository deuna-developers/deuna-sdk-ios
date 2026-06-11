import DeunaSDK
import Foundation

/// Central place for translating tester config into SDK widget init/config calls.
struct WidgetConfigBuilder {
    private let definitions = WidgetDefinitions()

    func makeEmbeddedConfiguration(
        from config: ExploreConfig,
        callbacks: WidgetCallbacksFactory
    ) -> DeunaWidgetConfiguration {
        let autoResize = config.presentationMode == .autoResize
        let domain = definitions.domainOrNil(config.domain)
        switch config.selectedWidget {
        case .paymentWidget:
            return PaymentWidgetConfiguration(
                orderToken: config.orderToken,
                callbacks: callbacks.payment(),
                userToken: definitions.tokenOrNil(config.userToken),
                hidePayButton: config.hidePayButton,
                behavior: definitions.splitPaymentBehavior(enabled: config.enableSplitPayment),
                domain: domain,
                autoResizeConfig: autoResize ? AutoResizeConfig(initialHeight: 100) : nil
            )
        case .checkoutWidget:
            return CheckoutWidgetConfiguration(
                orderToken: config.orderToken,
                callbacks: callbacks.checkout(),
                userToken: definitions.tokenOrNil(config.userToken),
                hidePayButton: config.hidePayButton,
                domain: domain,
                autoResizeConfig: autoResize ? AutoResizeConfig(initialHeight: 100) : nil
            )
        case .vaultWidget:
            return ElementsWidgetConfiguration(
                userToken: definitions.tokenOrNil(config.userToken),
                callbacks: callbacks.elements(),
                userInfo: definitions.fallbackUserInfoIfNeeded(config),
                orderToken: definitions.tokenOrNil(config.orderToken),
                hidePayButton: config.hidePayButton,
                behavior: definitions.splitPaymentBehavior(enabled: config.enableSplitPayment),
                domain: domain,
                autoResizeConfig: autoResize ? AutoResizeConfig(initialHeight: 100) : nil
            )
        case .nextActionWidget:
            return NextActionWidgetConfiguration(
                orderToken: config.orderToken,
                callbacks: callbacks.nextAction(),
                domain: domain,
                autoResizeConfig: autoResize ? AutoResizeConfig(initialHeight: 100) : nil
            )
        case .voucherWidget:
            return VoucherWidgetConfiguration(
                orderToken: config.orderToken,
                callbacks: callbacks.voucher(),
                domain: domain,
                autoResizeConfig: autoResize ? AutoResizeConfig(initialHeight: 100) : nil
            )
        case .clickToPayWidget:
            return ElementsWidgetConfiguration(
                userToken: definitions.tokenOrNil(config.userToken),
                callbacks: callbacks.elements(),
                userInfo: definitions.fallbackUserInfoIfNeeded(config),
                types: [["name": ElementsWidget.clickToPay]],
                orderToken: definitions.tokenOrNil(config.orderToken),
                hidePayButton: config.hidePayButton,
                domain: domain,
                autoResizeConfig: autoResize ? AutoResizeConfig(initialHeight: 100) : nil
            )
        }
    }

    func launchModalWidget(
        using sdk: DeunaSDK,
        config: ExploreConfig,
        callbacks: WidgetCallbacksFactory
    ) {
        let domain = definitions.domainOrNil(config.domain)
        switch config.selectedWidget {
        case .paymentWidget:
            sdk.initPaymentWidget(
                orderToken: config.orderToken,
                callbacks: callbacks.payment(),
                userToken: definitions.tokenOrNil(config.userToken),
                behavior: definitions.splitPaymentBehavior(enabled: config.enableSplitPayment),
                domain: domain
            )
        case .checkoutWidget:
            sdk.initCheckout(
                orderToken: config.orderToken,
                callbacks: callbacks.checkout(),
                userToken: definitions.tokenOrNil(config.userToken),
                domain: domain
            )
        case .vaultWidget:
            sdk.initElements(
                userToken: definitions.tokenOrNil(config.userToken),
                callbacks: callbacks.elements(),
                userInfo: definitions.fallbackUserInfoIfNeeded(config),
                orderToken: definitions.tokenOrNil(config.orderToken),
                behavior: definitions.splitPaymentBehavior(enabled: config.enableSplitPayment),
                domain: domain
            )
        case .nextActionWidget:
            sdk.initNextAction(orderToken: config.orderToken, callbacks: callbacks.nextAction(), domain: domain)
        case .voucherWidget:
            sdk.initVoucher(orderToken: config.orderToken, callbacks: callbacks.voucher(), domain: domain)
        case .clickToPayWidget:
            sdk.initElements(
                userToken: definitions.tokenOrNil(config.userToken),
                callbacks: callbacks.elements(),
                userInfo: definitions.fallbackUserInfoIfNeeded(config),
                types: [["name": ElementsWidget.clickToPay]],
                orderToken: definitions.tokenOrNil(config.orderToken),
                domain: domain
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
            hidePayButton: config.hidePayButton,
            domain: definitions.domainOrNil(config.domain)
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
            paymentMethods: [["paymentMethod": apm.paymentMethod, "processors": [apm.processor]]],
            domain: definitions.domainOrNil(config.domain)
        )
    }
}
