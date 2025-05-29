//
//  Mocks.swift
//  basic-integration
//
//  Created by deuna on 2/4/25.
//

import DeunaSDK

class Mocks {
    static var deunaSDK = DeunaSDK(
        environment: .staging,
        publicApiKey: "FAKE_API_KEY"
    )
}
