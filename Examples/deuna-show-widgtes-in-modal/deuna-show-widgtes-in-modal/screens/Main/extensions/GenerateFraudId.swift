extension MainScreen {
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
