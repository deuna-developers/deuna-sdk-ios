//
//  clickToPay.swift
//  basic-integration
//
//  Created by DEUNA on 2/9/24.
//

import DeunaSDK
import Foundation

extension ViewModel {
    /// Initiates the Click To Pay process
    /// - Parameters:
    ///   - completion: A closure to be executed upon completion of the click to pay process. It provides either an ElementsResponse on success or a DeUnaErrorMessage on failure.
    func clickToPay(completion: @escaping (ElementsResult) -> Void) {
        deunaSDK.initElements(
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
                onClosed: nil,
                onCanceled: {
                    // Click to pay was canceled by user
                    completion(.canceled)
                },
                onEventDispatch: { type, data in
                    print("👀 onEventDispatch: \(type) , \(data.formattedJson() ?? "")")
                }
            ),
            userInfo: DeunaSDK.UserInfo(firstName: "Darwin", lastName: "Morocho", email: "dmorocho+3@deuna.com"), // required for Click To Pay
            types: [
                [
                    "name": ElementsWidget.clickToPay // PASS THIS FOR CLICK TO PAY
                ]
            ]
        )
    }
}
