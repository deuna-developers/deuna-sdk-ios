//
//  ViewModel.swift
//  basic-integration
//
//  Created by Darwin Morocho on 8/3/24.
//

import DeunaSDK
import Foundation

enum PaymentWidgetResult {
    case canceled
    case success(CheckoutResponseData)
    case error(PaymentWidgetsErrorType)
}

enum CheckoutResult {
    case canceled
    case success(CheckoutResponse)
    case error(CheckoutError)
}

enum ElementsResult {
    case canceled
    case success(ElementsResponse)
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

    func initPaymentWidget(completion: @escaping (PaymentWidgetResult) -> Void) {
        deunaSDK.initPaymentWidget(
            orderToken: orderToken.trimmingCharacters(in: .whitespacesAndNewlines),
            callbacks: PaymentWidgetCallbacks(
                onSuccess: { data in
                    // Handle successful payment
                    self.deunaSDK.closePaymentWidget() // close the widget
                    completion(.success(data))
                },
                onError: { type in
                    switch type {
                    case .paymentError, .unknownError:
                        // there was an error during the payment process
                        self.deunaSDK.closePaymentWidget() // close the widget
                        completion(.error(type)) // notify the error
                        break
                    default:
                        break
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
                    
                    print("✋ onCardBinDetected: \(metadata!)")
                    
                    refetchOrder() { order in
                        print("✋  onCardBinDetected > refetchOrder \(String(describing: order))")
                    }
                    
                },
                onInstallmentSelected: { metadata, refetchOrder in
                    
                    guard metadata != nil else {
                        return
                    }
                    
                    print("✋ onInstallmentSelected: \(metadata!)")
                    
                    refetchOrder() { order in
                        print("✋  onInstallmentSelected > refetchOrder: \(String(describing: order))")
                    }
                }
            )
        )
    }

    /// Initiates the payment process.
    /// - Parameters:
    ///   - completion: A closure to be executed upon completion of the payment process. It provides either a CheckoutResponse on success or a DeUnaErrorMessage on failure.
    func initCheckout(completion: @escaping (CheckoutResult) -> Void) {
        deunaSDK.initCheckout(
            orderToken: orderToken.trimmingCharacters(in: .whitespacesAndNewlines),
            callbacks: CheckoutCallbacks(
                onSuccess: { response in
                    // Handle successful payment
                    self.deunaSDK.closeCheckout()
                    completion(.success(response))
                },
                onError: { error in
                    print(error.type)
                    // Handle payment error
                    self.deunaSDK.closeCheckout()
                    completion(.error(error))
                },
                onClosed: {
                    // DEUNA widget was closed
                },
                onCanceled: {
                    // Payment was canceled by user
                    completion(.canceled)
                },
                eventListener: { event, _ in
                    if event == .changeCart || event == .changeAddress {
                        self.deunaSDK.closeCheckout()
                        completion(.canceled)
                    }
                }
            )
        )
    }

    /// Initiates the process of saving a card.
    /// - Parameters:
    ///   - completion: A closure to be executed upon completion of the card saving process. It provides either an ElementsResponse on success or a DeUnaErrorMessage on failure.
    func saveCard(completion: @escaping (ElementsResult) -> Void) {
        deunaSDK.initElements(
            userToken: userToken.trimmingCharacters(in: .whitespacesAndNewlines),
            callbacks: ElementsCallbacks(
                onSuccess: { response in
                    // payment successful
                    self.deunaSDK.closeElements()
                    completion(.success(response))
                },
                onError: { error in
                    self.deunaSDK.closeElements()
                    completion(.error(error))
                },
                onClosed: {
                    // DEUNA widget was closed
                },
                onCanceled: {
                    // Saving card was canceled by user
                    completion(.canceled)
                },
                eventListener: { _, _ in
                }
            )
        )
    }
}
