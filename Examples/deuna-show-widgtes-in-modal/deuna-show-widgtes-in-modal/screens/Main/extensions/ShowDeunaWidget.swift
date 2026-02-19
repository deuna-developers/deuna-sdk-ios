import DeunaSDK
import Foundation

extension MainScreen {
    private func printSuccessMetadata(_ data: [String: Any]) {
        let userAgentValue = (data["user_agent"] as? String) ?? "nil"
        let fraudIdValue = (data["fraud_id"] as? String) ?? "nil"
        print("✅ DeunaSDK onSuccess user_agent: \(userAgentValue)")
        print("✅ DeunaSDK onSuccess fraud_id: \(fraudIdValue)")
    }

    func handlePaymentSuccess(_ data: [String: Any]) {
        printSuccessMetadata(data)
        deunaSDK.close {
            // go to payment success screen
            if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
                navigationPath.append(NavigationDestination.paymentSuccess(orderJsonData: jsonData))
            }
        }
    }

    func handleSaveCardSuccess(_ data: [String: Any]) {
        printSuccessMetadata(data)
        deunaSDK.close(){
            guard let savedCardData = (data["metadata"] as? Json)?["createdCard"] as? Json else {
                return
            }
            // go to save card success screen
            if let jsonData = try? JSONSerialization.data(withJSONObject: savedCardData) {
                navigationPath.append(NavigationDestination.saveCardSuccess(cardJsonData: jsonData))
            }
        }
    }

    func showWidget() {
        switch widgetToShow {
        case .paymentWidget:
            deunaSDK.initPaymentWidget(
                orderToken: orderToken,
                callbacks: PaymentWidgetCallbacks(
                    onSuccess: handlePaymentSuccess,
                    onError: { error in
                        print(error)
                    },
                    onClosed: { action in
                        print("DeunaSDK: Closed widget with action: \(action.self)")
                    },
                    onEventDispatch: { event, data in
                            print("event: \(event) \(data)")
                    }
                ),
                userToken: userToken,
//                paymentMethods: [
//                    [
//                        "paymentMethod": "bnpl",
//                        "processors": [
//                            "addi"
//                        ]
//                    ]
//                ],
//                behavior: [
//                    "paymentMethods": [
//                        "creditCard": [
//                            "splitPayments": [
//                                "maxCards": 2
//                            ],
//                            "flow": "purchase"
//                        ]
//                    ]
//                ]
                fraudCredentials: [
                    "RISKIFIED": [
                        "storeDomain": "deuna.com"
                    ]
                ],
            )
        case .nextActionWidget:
            deunaSDK.initNextAction(
                orderToken: orderToken,
                callbacks: NextActionCallbacks(
                    onSuccess: handlePaymentSuccess,
                    onError: { error in
                        print(error)
                    }
                )
            )
        case .voucherWidget:
            deunaSDK.initVoucher(
                orderToken: orderToken,
                callbacks: VoucherCallbacks(
                    onSuccess: handlePaymentSuccess,
                    onError: { error in
                        print(error)
                    }
                )
            )
        case .checkoutWidget:
            deunaSDK.initCheckout(
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
            deunaSDK.initElements(
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
                userInfo: DeunaSDK.UserInfo(
                    firstName: "John",
                    lastName: "Doe",
                    email: "4206122.qa@deuna.com"
                ),
                orderToken: orderToken,
                fraudCredentials: [
                    "RISKIFIED": [
                        "storeDomain": "deuna.com"
                    ]
                ]
//                behavior: [
//                    "paymentMethods": [
//                        "creditCard": [
//                            "splitPayments": [
//                                "maxCards": 2
//                            ],
//                            "flow": "purchase"
//                        ]
//                    ]
//                ]
            )
        case .clickToPayWidget:
            deunaSDK.initElements(
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
