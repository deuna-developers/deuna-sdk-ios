//
//  saveCard.swift
//  basic-integration
//
//  Created by DEUNA on 2/9/24.
//

import DeunaSDK
import Foundation

extension ViewModel {
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
                onClosed: { action in
                    // DEUNA widget was closed
                    if action == .userAction {
                        print("👀 The operation was canceled")
                        completion(.canceled)
                    }
                },
                onEventDispatch: { type, data in
                    print("👀 onEventDispatch: \(type) , \(data.formattedJson() ?? "")")
                }
            ),
            userInfo: getUserToken() == nil ? DeunaSDK.UserInfo(firstName: "Darwin", lastName: "Morocho", email: "dmorocho@deuna.com") : nil,
            styleFile: "89958449-2423-11ef-97c7-0a58a9feac02",
            widgetExperience: ElementsWidgetExperience(
                userExperience: ElementsWidgetExperience.UserExperience(
                    showSavedCardFlow: true, defaultCardFlow: true
                )
            ),
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
    }
}
