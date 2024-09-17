//
//  PaymentWidgetEventHandler.swift
//
//
//  Created by deuna on 27/6/24.
//

import Foundation
import WebKit

extension PaymentWidgetViewController {
    public func handleEventData(message: BaseWebViewController.Message) {
        let json = message.json
        guard let type = json["type"] as? String, let data = json["data"] as? [String: Any] else {
            return
        }

        guard let event = CheckoutEvent(rawValue: type) else {
            return
        }

        callbacks.onEventDispatch?(event, data)

        // Invoke appropriate callbacks based on event type
        switch event {
        case .purchaseError, .purchaseRejected:
            setCloseEnabled(true)
            closeSubWebViewController()
            if let error = PaymentsError.fromJson(data: data) {
                callbacks.onError?(error)
            }
        case .purchase, .apmSuccess:
            closeSubWebViewController()
            callbacks.onSuccess?(data["order"] as! Json)
        case .paymentMethods3dsInitiated, .apmClickRedirect:
            threeDsAuth = true
        case .linkClose:
            closeWebView(.userAction)
        case .onBinDetected:
            handleOnBinDetected(jsonMetadata: data["metadata"] as? Json)
        case .onInstallmentSelected:
            handleOnInstallmentSelected(jsonMetadata: data["metadata"] as? Json)
        case .paymentProcessing:
            callbacks.onPaymentProcessing?()
            setCloseEnabled(false)
        default:
            // Do nothing
            DeunaLogs.info(event.rawValue)
        }
    }

    func handleOnBinDetected(jsonMetadata: [String: Any]?) {
        callbacks.onCardBinDetected?(jsonMetadata)
    }

    func handleOnInstallmentSelected(jsonMetadata: [String: Any]?) {
        callbacks.onInstallmentSelected?(jsonMetadata)
    }
}
