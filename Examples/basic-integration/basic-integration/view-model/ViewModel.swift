//
//  ViewModel.swift
//  basic-integration
//
//  Created by DEUNA on 8/3/24.
//

import DeunaSDK
import Foundation

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

    func getUserToken() -> String? {
        let token = userToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if token.isEmpty {
            return nil
        }
        return token
    }
}
