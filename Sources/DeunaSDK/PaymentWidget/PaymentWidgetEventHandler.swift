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
    public func handleEventData(message: BaseWebViewController.Message) {
        let json = message.json
        guard let type = json["type"] as? String, let data = json["data"] as? [String: Any] else {
            return
        }

        // This event is emitted by the widget when the download voucher button is pressed
        if type == APMsConstants.apmSaveId {
            if let voucherUrl = (data[APMsConstants.metadata] as? Json)?[APMsConstants.voucherPdfDownloadUrl] as? String {
                showLoader()
                downloadPdf(urlString: voucherUrl) {
                    self.hideLoader()
                }

            } else {
                downloadVoucher()
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

    /// Uses js injection with html2canvas library to take a screen shoot of the web page loaded in the web view
    func downloadVoucher() {
        let js = """
        (function() {
            function captureInvoice() {
                html2canvas(document.body, { allowTaint:true, useCORS: true }).then((canvas) => {
                    // Convert the canvas to a base64 image
                    var imgData = canvas.toDataURL("image/png");
                    // Emit a local post message with the image as a base64 string.
                    window.webkit.messageHandlers.\(WebViewUserContentControllerNames.saveBase64Image).postMessage(imgData);
                });
            }

            // If html2canvas is not added
            if (typeof html2canvas === "undefined") {
                var script = document.createElement("script");
                script.src = "https://html2canvas.hertzen.com/dist/html2canvas.min.js";
                script.onload = function () {
                    captureInvoice();
                };
                document.head.appendChild(script);
            } else { captureInvoice(); }
        })();
        """

        webView?.evaluateJavaScript(js)
    }
}
