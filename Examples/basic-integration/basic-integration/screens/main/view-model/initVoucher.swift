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
    func initVoucher(completion: @escaping (PaymentWidgetResult) -> Void) {
        deunaSDK.initVoucher(
            orderToken: orderToken.trimmingCharacters(in: .whitespacesAndNewlines),
            callbacks: VoucherCallbacks(
                onSuccess: { order in
                    print("✅ DeunaSDK onSuccess: \(order.formattedJson() ?? "")")
                    // Handle successful payment
                    self.deunaSDK.close() // close the widget
                    completion(.success(order))
                },
                onError: { error in
                    
                    print("❌ DeunaSDK onError code: \(error.metadata?.code)")
                    print("❌ DeunaSDK onError message: \(error.metadata?.message)")
                    
                    // The widget could not be loaded
                    if error.type == .initializationFailed {
                        self.deunaSDK.close() // close the widget
                        return
                    }
                    
                    // The payment was failed
                    if(error.type == .paymentError){
                        // YOUR CODE HERE
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
                onEventDispatch: { event, data in
                    print("👀 DeunaSDK onEventDispatch \(event): \(data)")
                }
            ),
            language: "en"
        )
    }
}

