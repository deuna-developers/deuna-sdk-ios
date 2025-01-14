//
//  initCheckout.swift
//  basic-integration
//
//  Created by DEUNA on 2/9/24.
//

import DeunaSDK
import Foundation

extension ViewModel {
    /// Initiates the payment process.
    /// - Parameters:
    ///   - completion: A closure to be executed upon completion of the payment process. It provides either a CheckoutResponse on success or a DeUnaErrorMessage on failure.
    func initCheckout(completion: @escaping (CheckoutResult) -> Void) {
        deunaSDK.initCheckout(
            orderToken: orderToken.trimmingCharacters(in: .whitespacesAndNewlines),
            callbacks: CheckoutCallbacks(
                onSuccess: { order in
                    print("✅ onSuccess: \(order.formattedJson() ?? "")")
                    // Handle successful payment
                    self.deunaSDK.close()
                    completion(.success(order))
                },
                onError: { error in
                    print("❌ onError order: \(error.order?.formattedJson() ?? "")")
                    print("❌ onError metadata code: \(error.metadata?.code ?? "")")
                    print("❌ onError metadata message: \(error.metadata?.message ?? "")")

                    if error.type == .initializationFailed || error.type == .orderCouldNotBeRetrieved {
                        // Handle payment error
                        self.deunaSDK.close()
                        completion(.error(error))
                        return
                    }
                },
                onClosed: { action in
                    // DEUNA widget was closed
                    if action == .userAction {
                        print("👀 The operation was canceled")
                        completion(.canceled)
                    }
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
            styleFile: "89958449-2423-11ef-97c7-0a58a9feac02"
        )
    }
}
