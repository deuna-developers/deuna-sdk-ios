//
//  ViewModel.swift
//  basic-integration
//
//  Created by Darwin Morocho on 8/3/24.
//

import DeunaSDK
import Foundation

extension [String: Any] {
    public func formattedJson() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            return nil
        } catch {
            print("Error converting dictionary to JSON: \(error.localizedDescription)")
            return nil
        }
    }
}

extension String {
    func toDictionary() -> [String: Any]? {
        guard let data = data(using: .utf8) else {
            return nil
        }

        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return dictionary
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}

struct Error: Identifiable {
    let id = UUID()
    let code: String
    let message: String

    init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

enum PaymentWidgetResult {
    case canceled
    case success([String: Any])
    case error(PaymentsError)
}

enum CheckoutResult {
    case canceled
    case success([String: Any])
    case error(PaymentsError)
}

enum ElementsResult {
    case canceled
    case success([String: Any])
    case error(ElementsError)
}

/// View model responsible for handling interactions between the UI and the DeunaSDK.
class ViewModel: ObservableObject {
    /// Instance of the DeunaSDK used for payment or elements processing.
    let deunaSDK: DeunaSDK

    /// The order token used for processing payments.
    @Published var orderToken = ""

    /// The user token used for saving cards.
    @Published var userToken = ""

    /// Initializes the ViewModel with the provided DeunaSDK instance.
    /// - Parameters:
    ///   - deunaSDK: An instance of the DeunaSDK.
    init(deunaSDK: DeunaSDK) {
        self.deunaSDK = deunaSDK
    }

    private func getUserToken() -> String? {
        let token = userToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if token.isEmpty {
            return nil
        }
        return token
    }

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
                onEventDispatch: { event ,  data in
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
                [ "name": "module_name" ]
            ]
        )
    }

    /// Initiates the payment process.
    /// - Parameters:
    ///   - completion: A closure to be executed upon completion of the payment process. It provides either a CheckoutResponse on success or a DeUnaErrorMessage on failure.
    func initCheckout(completion: @escaping (CheckoutResult) -> Void) {
        deunaSDK.initCheckout(
            orderToken: orderToken.trimmingCharacters(in: .whitespacesAndNewlines),
            callbacks: CheckoutCallbacks(
                onSuccess: { data in
                    print("✅ onSuccess: \(data.formattedJson() ?? "")")
                    // Handle successful payment
                    self.deunaSDK.close()
                    completion(.success(data))
                },
                onError: { error in
                    print("❌ onError order: \(error.order?.formattedJson() ?? "")")
                    print("❌ onError metadata code: \(error.metadata?.code ?? "")")
                    print("❌ onError metadata message: \(error.metadata?.message ?? "")")

                    if error.type == .initializationFailed {
                        // Handle payment error
                        self.deunaSDK.close()
                        completion(.error(error))
                        return
                    }
                },
                onClosed: {
                    // DEUNA widget was closed
                },
                onCanceled: {
                    // Payment was canceled by user
                    completion(.canceled)
                },
                onEventDispatch: { event, data in
                    print("👀 onEventDispatch: \(event) , \(data.formattedJson() ?? "")")

                    if event == .changeCart || event == .changeAddress {
                        self.deunaSDK.close()
                        completion(.canceled)
                    }
                }
            ),
            userToken: getUserToken(),
            cssFile: "89958449-2423-11ef-97c7-0a58a9feac02"
        )
    }

    /// Initiates the process of saving a card.
    /// - Parameters:
    ///   - completion: A closure to be executed upon completion of the card saving process. It provides either an ElementsResponse on success or a DeUnaErrorMessage on failure.
    func saveCard(completion: @escaping (ElementsResult) -> Void) {
        deunaSDK.initElements(
            userToken: getUserToken(),
            callbacks: ElementsCallbacks(
                onSuccess: { data in
                    print("✅ onSuccess: \(data.formattedJson() ?? "")")
                    // payment successful
                    self.deunaSDK.close()
                    completion(.success(data))
                },
                onError: { error in
                    print("❌ onError user: \(error.user?.formattedJson() ?? "")")
                    print("❌ onError metadata code: \(error.metadata?.code ?? "")")
                    print("❌ onError metadata message: \(error.metadata?.message ?? "")")
                    self.deunaSDK.close()
                    completion(.error(error))
                },
                onClosed: {
                    // DEUNA widget was closed
                },
                onCanceled: {
                    // Saving card was canceled by user
                    completion(.canceled)
                },
                onEventDispatch: { type, data in
                    print("👀 onEventDispatch: \(type) , \(data.formattedJson() ?? "")")
                }
            ),
            userInfo: getUserToken() == nil ? DeunaSDK.UserInfo(firstName: "Darwin", lastName: "Morocho", email: "dmorocho+1@deuna.com") : nil,
            cssFile: "89958449-2423-11ef-97c7-0a58a9feac02"
        )
    }
}
