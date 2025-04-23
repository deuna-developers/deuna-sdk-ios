//
//  DeunaWidget.swift
//  basic-integration
//
//  Created by deuna on 26/3/25.
//

import DeunaSDK
import SwiftUI
import SwiftUICore

struct DeunaWidgetWrapper: View {
    let deunaSDK: DeunaSDK
    let orderToken: String?
    let userToken: String?
    let widgetToShow: WidgetToShow
    let onBack: () -> Void
    let handlePaymentSuccess: (Json) -> Void
    let handleCardSavedSuccess: (SuccessType, Json) -> Void
    let setError: (Error) -> Void

    var body: some View {
        let configuration: DeunaWidgetConfiguration

        switch widgetToShow {
        case .paymentWidget:
            configuration = PaymentWidgetConfiguration(
                orderToken: orderToken ?? "",
                callbacks: PaymentWidgetCallbacks(
                    onSuccess: { order in
                        handlePaymentSuccess(order)
                        deunaSDK.dispose()
                    },
                    onError: { error in
                        setError(
                            Error(
                                code: error.metadata?.code ?? "ERROR",
                                message: error.metadata?.message ?? "Unknown error"
                            )
                        )
                    }
                ),
                hidePayButton: true
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
            
        case .nextActionWidget:
            configuration = NextActionWidgetConfiguration(
                orderToken: orderToken ?? "",
                callbacks: NextActionCallbacks(
                    onSuccess: { order in
                        handlePaymentSuccess(order)
                        deunaSDK.dispose()
                    },
                    onError: { error in
                        setError(
                            Error(
                                code: error.metadata?.code ?? "ERROR",
                                message: error.metadata?.message ?? "Unknown error"
                            )
                        )
                    }
                )
            )
            
        case .voucherWidget:
            configuration = VoucherWidgetConfiguration(
                orderToken: orderToken ?? "",
                callbacks: VoucherCallbacks(
                    onSuccess: { order in
                        handlePaymentSuccess(order)
                        deunaSDK.dispose()
                    },
                    onError: { error in
                        setError(
                            Error(
                                code: error.metadata?.code ?? "ERROR",
                                message: error.metadata?.message ?? "Unknown error"
                            )
                        )
                    }
                )
            )


        case .vaultWidget:
            configuration = ElementsWidgetConfiguration(
                callbacks: ElementsCallbacks(
                    onSuccess: { data in
                        handleCardSavedSuccess(.saveCard, data)
                        // NOTE: Explicitly release widget resources when no longer needed
                        // to prevent memory leaks and ensure proper cleanup.
                        deunaSDK.dispose()
                    },
                    onError: { error in
                        setError(
                            Error(
                                code: error.metadata?.code ?? "ERROR",
                                message: error.metadata?.message ?? "Unknown error"
                            )
                        )
                    },
                    onClosed: { _ in },
                    onEventDispatch: { _, _ in }
                ),
                userInfo: DeunaSDK.UserInfo(
                    firstName: "Darwin",
                    lastName: "Morocho",
                    email: "dmorocho+10@deuna.com"
                ),
                orderToken: orderToken,
                behavior: [
                    "paymentMethods": [
                        "creditCard": [
                            "splitPayments": [
                                "maxCards": 2
                            ],
                            "flow": "purchase"
                        ]
                    ]
                ]
            )

        case .checkoutWidget:
            configuration = CheckoutWidgetConfiguration(
                orderToken: orderToken ?? "",
                callbacks: CheckoutCallbacks(
                    onSuccess: { order in
                        handlePaymentSuccess(order)
                        deunaSDK.dispose()
                    },
                    onError: { error in
                        setError(
                            Error(
                                code: error.metadata?.code ?? "ERROR",
                                message: error.metadata?.message ?? "Unknown error"
                            )
                        )
                    },
                    onClosed: { _ in },
                    onEventDispatch: { _, _ in }
                )
            )

        case .clickToPayWidget:
            configuration = ElementsWidgetConfiguration(
                callbacks: ElementsCallbacks(
                    onSuccess: { data in
                        handleCardSavedSuccess(.saveCard, data)
                        deunaSDK.dispose()
                    },
                    onError: { error in
                        setError(
                            Error(
                                code: error.metadata?.code ?? "ERROR",
                                message: error.metadata?.message ?? "Unknown error"
                            )
                        )
                    },
                    onClosed: { _ in },
                    onEventDispatch: { _, _ in }
                ),
                types: [
                    [
                        "name": ElementsWidget.clickToPay // PASS THIS FOR CLICK TO PAY
                    ]
                ],
                orderToken: orderToken ?? ""
            )
        }

        return VStack {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                .padding()
                Spacer()
                Text("Confirm & Pay").padding()
            }

            DeunaWidget(
                deunaSDK: deunaSDK,
                configuration: configuration
            )

            Button(action: {
                deunaSDK.isValid { isValid in
                    print("✅ isValid: \(isValid)")
                    guard isValid else { return }
                    
                    deunaSDK.submit { result in
                        print("🧪 submit result: \(result.status)")
                        if result.status == .error {
                            setError(Error(code: "ERROR", message: result.message ?? "Unknown error"))
                        }
                    }
                }
            }) {
                Text("PAY").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }.background(Color(.systemGray6))
    }
}

#Preview {
    struct DeunaWidgetPreviewWrapper: View {
        var body: some View {
            DeunaWidgetWrapper(
                deunaSDK: Mocks.deunaSDK,
                orderToken: "YOUR_ORDER_TOKEN",
                userToken: "",
                widgetToShow: .paymentWidget,
                onBack: {
                    print("Back tapped from preview")
                },
                handlePaymentSuccess: { _ in },
                handleCardSavedSuccess: { _, _ in },
                setError: { _ in }
            )
        }
    }

    return DeunaWidgetPreviewWrapper()
}
