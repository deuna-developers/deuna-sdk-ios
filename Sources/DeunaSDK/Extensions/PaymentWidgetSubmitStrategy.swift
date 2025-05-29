//
//  PaymentWidgetSubmitStrategy.swift
//  DeunaSDK
//
//  Created by Darwin on 28/5/25.
//

extension DeunaSDK {
    func paymentWidgetSubmitStrategy(
        completion: @escaping (SubmitResult) -> Void
    ) {
        guard let controller = paymentWidgetViewController else {
            completion(SubmitResult(status: .error))
            return
        }
        
        let widgetConfig = controller.widgetConfig
        
        getWidgetState { state in
            guard let selectedPaymentMethod = (state?["paymentMethods"] as? Json)?["selectedPaymentMethod"] as? Json else {
                DeunaLogs.info("selectedPaymentMethod null")
                controller.submit(completion: completion)
                return
            }
           
            let TWO_STEP_FLOW = "twoStep"

            let processorName = selectedPaymentMethod["processor_name"] as? String

            let configFlowType = ((selectedPaymentMethod["configuration"] as? Json)?["flowType"] as? Json)?["type"] as? String
            
            let behaviorFlowType = ((widgetConfig.behavior?["paymentMethods"] as? Json)?["flowType"] as? Json)?["type"] as? String
                      
            let isTwoStepFlow = (configFlowType == TWO_STEP_FLOW) || (configFlowType == nil && behaviorFlowType == TWO_STEP_FLOW)
        
            
            guard isTwoStepFlow && processorName == "paypal_wallet" else {
               controller.submit(completion: completion)
               return
            }
            
            
            let newInstanceSdk = DeunaSDK(
                environment: self.environment,
                publicApiKey: self.publicApiKey,
                useMainThread: DeunaTasks.useMainThread
            )
            
            newInstanceSdk.initPaymentWidget(
                orderToken: controller.widgetConfig.orderToken,
                callbacks: PaymentWidgetCallbacks(
                    onSuccess: { _ in
                        newInstanceSdk.close()
                    },
                    onError: { _ in
                       newInstanceSdk.close()
                    }
                ),
                userToken: controller.widgetConfig.userToken,
                paymentMethods: [
                    [
                        "paymentMethod":"wallet",
                        "processors": ["paypal_wallet"],
                        "configuration": [
                            "express":  true,
                            "flowType": [
                                "type": TWO_STEP_FLOW
                            ]
                        ]
                    ]
                ]
            )
            completion(SubmitResult(status: .success))
        }
    }
}
