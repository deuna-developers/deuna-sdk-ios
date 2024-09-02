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
}
