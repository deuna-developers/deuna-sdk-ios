//
//  generateFraudId.swift
//  basic-integration
//
//  Created by deuna on 9/4/25.
//

extension ViewModel {
    func generateFraudId() {
        deunaSDK.generateFraudId(
            params: [
                "RISKIFIED": [
                    "storeDomain": "volaris.com"
                ]
            ]
        ) { fraudId in
            self.fraudId = fraudId ?? "ERROR"
        }
    }
}
