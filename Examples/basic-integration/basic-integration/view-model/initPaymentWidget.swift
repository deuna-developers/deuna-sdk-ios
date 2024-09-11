//
//  initPaymentWidget.swift
//  basic-integration
//
//  Created by DEUNA on 2/9/24.
//

import DeunaSDK
import Foundation

extension ViewModel {
    /// Launches the payment widget with a given order token
    func initPaymentWidget(completion: @escaping (PaymentWidgetResult) -> Void) {
        deunaSDK.initPaymentWidget(
            orderToken: orderToken.trimmingCharacters(in: .whitespacesAndNewlines),
            callbacks: PaymentWidgetCallbacks(
                onSuccess: { order in
                    print("✅ DeunaSDK onSuccess: \(order.formattedJson() ?? "")")
                    // Handle successful payment
                    self.deunaSDK.close() // close the widget
                    completion(.success(order))
                },
                onError: { error in
                
                    print("❌ onError metadata code: \(error.metadata?.code ?? "")")
                    print("❌ onError metadata message: \(error.metadata?.message ?? "")")

                    let type: PaymentsError.ErrorType = error.type

                    if type == .initializationFailed {
                        self.deunaSDK.close() // close the widget
                        completion(.error(error))
                        return
                    }
                },
                onClosed: { action in
                    print("👀 DeunaSDK action \(action)")
                    // DEUNA widget was closed
                    if action == .userAction {
                        print("👀 DeunaSDK The operation was canceled")
                        completion(.canceled)
                    }
                },
                onCardBinDetected: { metadata in

                    guard metadata != nil else {
                        return
                    }

                    print("✋ DeunaSDK onCardBinDetected: \(metadata!.formattedJson() ?? "")")

                    /// Set a custom style when the onCardBinDetected callback is called
                    self.deunaSDK.setCustomStyle(data: """
                        {
                          "theme": {
                            "colors": {
                              "primaryTextColor": "#023047",
                              "backgroundSecondary": "#8ECAE6",
                              "backgroundPrimary": "#8ECAE6",
                              "buttonPrimaryFill": "#FFB703",
                              "buttonPrimaryHover": "#FFB703",
                              "buttonPrimaryText": "#000000",
                              "buttonPrimaryActive": "#FFB703"
                            }
                          },
                          "HeaderPattern": {
                            "overrides": {
                              "Logo": {
                                "props": {
                                  "url": "https://images-staging.getduna.com/ema/fc78ef09-ffc7-4d04-aec3-4c2a2023b336/test2.png"
                                }
                              }
                            }
                          }
                        }
                        """.toDictionary() ?? [:]
                    )

                },
                onInstallmentSelected: { metadata in
                    guard metadata != nil else {
                        return
                    }

                    print("✋ DeunaSDK onInstallmentSelected: \(metadata!.formattedJson() ?? "")")
                },
                onPaymentProcessing: {
                    print("👀 DeunaSDK onPaymentProcessing")
                },
                onEventDispatch: { event, data in
                    print("👀 DeunaSDK onEventDispatch \(event)")
                }
            ),
            userToken: getUserToken(),
            styleFile: "89958449-2423-11ef-97c7-0a58a9feac02"
        )
    }
}
