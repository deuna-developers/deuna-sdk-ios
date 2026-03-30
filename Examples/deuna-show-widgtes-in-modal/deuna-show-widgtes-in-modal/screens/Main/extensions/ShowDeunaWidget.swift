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
        // Get domains from environment variables for e2e-preproduction
        let checkoutDomain = ProcessInfo.processInfo.environment["DEUNA_CHECKOUT_BASE_DOMAIN"]  // checkout-base
        let elementsDomain = ProcessInfo.processInfo.environment["DEUNA_ELEMENTS_LINK_DOMAIN"]   // elements-link
        
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
                    onCardBinDetected: { metadata in
                      guard let metadata else { return }
                      print("DeunaSDK: Card bin detected: \(metadata)")
                    },
                    onInstallmentSelected: { metadata in
                        guard let metadata else { return }
                        print("DeunaSDK: onInstallmentSelected: \(metadata)")
                    },
                    onEventDispatch: { event, json in
                        if event == .paymentMethodsEntered {
                            TestNotificationHelper.post(.paymentMethodsEntered)
                        }
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
                domain: checkoutDomain  // ← Use checkout-base domain for e2e-preproduction
            )
        case .nextActionWidget:
            deunaSDK.initNextAction(
                orderToken: orderToken,
                callbacks: NextActionCallbacks(
                    onSuccess: handlePaymentSuccess,
                    onError: { error in
                        print(error)
                    }
                ),
                domain: checkoutDomain  // ← Use checkout-base domain for e2e-preproduction
            )
        case .voucherWidget:
            deunaSDK.initVoucher(
                orderToken: orderToken,
                callbacks: VoucherCallbacks(
                    onSuccess: handlePaymentSuccess,
                    onError: { error in
                        print(error)
                    }
                ),
                domain: checkoutDomain  // ← Use checkout-base domain for e2e-preproduction
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
                ),
                domain: checkoutDomain  // ← Use checkout-base domain for e2e-preproduction
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
                    onCardBinDetected: { metadata in
                      guard let metadata else { return }
                      print("DeunaSDK: Card bin detected: \(metadata)")
                    },
                    onInstallmentSelected: { metadata in
                        guard let metadata else { return }
                        print("DeunaSDK: onInstallmentSelected: \(metadata)")
                    },
                    onEventDispatch: { _, _ in
                    }
                ),
                userInfo: DeunaSDK.UserInfo(
                    firstName: "John",
                    lastName: "Doe",
                    email: "4206122.qa@deuna.com"
                ),
                orderToken: orderToken,
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
                domain: elementsDomain  // ← Use elements-link domain for e2e-preproduction
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
                orderToken: orderToken,
                domain: elementsDomain  // ← Use elements-link domain for e2e-preproduction
            )
        }
    }
}
