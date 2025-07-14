import DeunaSDK
import Foundation

extension MainScreen {
    func releaseWidgetResources() {
        config = nil
        deunaSDK.dispose()
    }
    
    func handlePaymentSuccess(_ data: [String: Any]) {
        releaseWidgetResources()
        // go to payment success screen
        if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
            navigationPath.append(NavigationDestination.paymentSuccess(orderJsonData: jsonData))
        }
    }
    
    func handleSaveCardSuccess(_ data: [String: Any]) {
        releaseWidgetResources()
        
        guard let savedCardData = (data["metadata"] as? Json)?["createdCard"] as? Json else {
            return
        }
        // go to save card success screen
        if let jsonData = try? JSONSerialization.data(withJSONObject: savedCardData) {
            navigationPath.append(NavigationDestination.saveCardSuccess(cardJsonData: jsonData))
        }
    }
    
    func setConfig() {
        switch widgetToShow {
        case .paymentWidget:
            config = PaymentWidgetConfiguration(
                orderToken: orderToken,
                callbacks: PaymentWidgetCallbacks(
                    onSuccess: handlePaymentSuccess,
                    onError: { error in
                        print(error)
                    }
                ),
                userToken: userToken,
                hidePayButton: true
            )
        case .nextActionWidget:
            config = NextActionWidgetConfiguration(
                orderToken: orderToken,
                callbacks: NextActionCallbacks(
                    onSuccess: handlePaymentSuccess,
                    onError: { error in
                        print(error)
                    }
                )
            )
        case .voucherWidget:
            config = VoucherWidgetConfiguration(
                orderToken: orderToken,
                callbacks: VoucherCallbacks(
                    onSuccess: handlePaymentSuccess,
                    onError: { error in
                        print(error)
                    }
                )
            )
        case .checkoutWidget:
            config = CheckoutWidgetConfiguration(
                orderToken: orderToken,
                callbacks: CheckoutCallbacks(
                    onSuccess: handlePaymentSuccess,
                    onError: { error in
                        print(error)
                    },
                    onClosed: nil,
                    onEventDispatch: { _, _ in
                    }
                )
            )
        case .vaultWidget:
            config = ElementsWidgetConfiguration(
                userToken: userToken.isEmpty ? nil : userToken,
                callbacks: ElementsCallbacks(
                    onSuccess: handleSaveCardSuccess,
                    onError: { error in
                        print(error)
                    },
                    onClosed: nil,
                    onEventDispatch: { _, _ in
                    }
                ),
                userInfo: userToken.isEmpty ? DeunaSDK.UserInfo(
                    firstName: "John",
                    lastName: "Doe",
                    email: "johndoe@example.com"
                ) : nil,
                orderToken: orderToken
            )
        case .clickToPayWidget:
            config = ElementsWidgetConfiguration(
                userToken: userToken.isEmpty ? nil : userToken,
                callbacks: ElementsCallbacks(
                    onSuccess: handleSaveCardSuccess,
                    onError: { error in
                        print(error)
                    },
                    onClosed: nil,
                    onEventDispatch: { _, _ in
                    }
                ),
                userInfo: userToken.isEmpty ? DeunaSDK.UserInfo(
                    firstName: "John",
                    lastName: "Doe",
                    email: "johndoe@example.com"
                ) : nil,
                types: [
                    [
                        "name": ElementsWidget.clickToPay // PASS THIS FOR CLICK TO PAY
                    ]
                ],
                orderToken: orderToken
            )
        }
    }
}
