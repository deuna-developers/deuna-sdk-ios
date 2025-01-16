//
//  PaymentWidgetEventHandler.swift
//
//
//  Created by deuna on 27/6/24.
//

import Foundation
import WebKit

private enum APMsConstants {
    static let apmSaveId = "apmSaveId"
    static let metadata = "metadata"
    static let voucherPdfDownloadUrl = "voucherPdfDownloadUrl"
}

extension PaymentWidgetViewController {
    public func handleEventData(message: DeunaWebViewController.Message) {
        let json = message.json
        guard let type = json["type"] as? String, let data = json["data"] as? [String: Any] else {
            return
        }

        // This event is emitted by the widget when the download voucher button is pressed
        if type == APMsConstants.apmSaveId {
            showLoader()
            if let voucherUrl = (data[APMsConstants.metadata] as? Json)?[APMsConstants.voucherPdfDownloadUrl] as? String {
                downloadFile(urlString: voucherUrl) {
                    self.hideLoader()
                }
            } else {
                webView?.takeSnapshot { _ in
                    self.hideLoader()
                }
            }
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
        case .onBinDetected:
            handleOnBinDetected(jsonMetadata: data["metadata"] as? Json)
        case .onInstallmentSelected:
            handleOnInstallmentSelected(jsonMetadata: data["metadata"] as? Json)
        case .paymentProcessing:
            callbacks.onPaymentProcessing?()
            setCloseEnabled(false)
        case .paymentMethodsStarted:
            // When the payment form is showed perform a scroll to the top page
            webView?.evaluateJavaScript("window.scrollTo(0, 0);")
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
