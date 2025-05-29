//
//  PaymentWidgetEventHandler.swift
//
//
//  Created by deuna on 27/6/24.
//

import Foundation
import WebKit

extension NextActionViewController {
    func handleEventData(message: WebViewController.Message) {
        let json = message.json
        guard let type = json["type"] as? String, let data = json["data"] as? [String: Any] else {
            return
        }

        // This event is emitted by the widget when the download voucher button is pressed
        if type == APMsConstants.apmSaveId {
            self.downloadVoucher(data: data)
            return
        }

        guard let event = CheckoutEvent(rawValue: type) else {
            return
        }

        callbacks.onEventDispatch?(event, data)

        // Invoke appropriate callbacks based on event type
        switch event {
        case .purchaseError:
            setCloseEnabled(true)
            closeSubWebViewController()
            if let error = PaymentsError.fromJson(data: data) {
                callbacks.onError?(error)
            }
        case .purchase:
            closeSubWebViewController()
            callbacks.onSuccess?(data["order"] as! Json)
        case .paymentMethods3dsInitiated, .apmClickRedirect:
            DeunaLogs.info("3Ds redirect, apm redirect")
        case .linkClose:
            closeWebView(.userAction)
        case .paymentMethodsStarted:
            // When the payment form is showed perform a scroll to the top page
            controller.webView?.evaluateJavaScript("window.scrollTo(0, 0);")
        default:
            // Do nothing
            DeunaLogs.info(event.rawValue)
        }
    }
}
