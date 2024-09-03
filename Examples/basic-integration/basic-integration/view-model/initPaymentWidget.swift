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
                onSuccess: { data in
                    print("✅ onSuccess: \(data.formattedJson() ?? "")")
                    // Handle successful payment
                    self.deunaSDK.close() // close the widget
                    completion(.success(data))
                },
                onError: { error in
                    print("❌ onError order: \(error.order?.formattedJson() ?? "")")
                    print("❌ onError metadata code: \(error.metadata?.code ?? "")")
                    print("❌ onError metadata message: \(error.metadata?.message ?? "")")

                    let type: PaymentsError.ErrorType = error.type

                    if type == .initializationFailed {
                        self.deunaSDK.close() // close the widget
                        completion(.error(error))
                        return
                    }
                },
                onClosed: {
                    // DEUNA widget was closed
                },
                onCanceled: {
                    completion(.canceled)
                },
                onCardBinDetected: { metadata, refetchOrder in

                    guard metadata != nil else {
                        return
                    }

                    print("✋ onCardBinDetected: \(metadata!.formattedJson() ?? "")")

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

                    refetchOrder { order in
                        print("✋  onCardBinDetected > refetchOrder \(order?.formattedJson() ?? "nil")")
                    }

                },
                onInstallmentSelected: { metadata, refetchOrder in

                    guard metadata != nil else {
                        return
                    }

                    print("✋ onInstallmentSelected: \(metadata!.formattedJson() ?? "")")

                    refetchOrder { order in
                        print("✋  onInstallmentSelected > refetchOrder: \(order?.formattedJson() ?? "nil")")
                    }
                },
                onPaymentProcessing: {
                    print("👀 onPaymentProcessing")
                },
                onEventDispatch: { event, data in
                    print("👀 onEventDispatch \(event): \(data.formattedJson() ?? "nil")")
                }
            ),
            userToken: getUserToken(),
            paymentMethods: [
                [
                    "payment_method": "paypal",
                    "processors": ["daviplata", "nequi_push_voucher"]
                ]
            ],
            checkoutModules: [
                ["name": "module_name"]
            ]
        )
    }
}
