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

        guard let event = PaymentWidgetEvent(rawValue: type) else {
            DeunaLogs.debug("Received unknown event type: \(type)")
            return
        }

        // Invoke appropriate callbacks based on event type
        switch event {
        case .purchaseError:
            if let error = PaymentsError.fromJson(data: data) {
                callbacks.onError?(error)
            }
        case .purchase:
            callbacks.onSuccess?(data)
        case .paymentMethods3dsInitiated:
            threeDsAuth = true
        case .linkClose:
            callbacks.onCanceled?()
            closeWebView()
        case .onBinDetected:
            handleOnBinDetected(jsonMetadata: data["metadata"] as? [String: Any])
        case .onInstallmentSelected:
            handleOnInstallmentSelected(jsonMetadata: data["metadata"] as? [String: Any])
        case .refetchOrder:
            handleOnRefetchOrder(json: json)
        }
    }

    func handleOnBinDetected(jsonMetadata: [String: Any]?) {
        guard jsonMetadata != nil else {
            callbacks.onCardBinDetected?(nil, refetchOrder)
            return
        }
        callbacks.onCardBinDetected?(jsonMetadata, refetchOrder)
    }

    func handleOnInstallmentSelected(jsonMetadata: [String: Any]?) {
        guard jsonMetadata != nil, jsonMetadata?["plan_option_id"] != nil else {
            callbacks.onInstallmentSelected?(nil, refetchOrder)
            return
        }
        callbacks.onInstallmentSelected?(jsonMetadata, refetchOrder)
    }

    func handleOnRefetchOrder(json: [String: Any]) {
        guard let requestId = json["requestId"] as? Int,
              let completition = refetchOrderRequests[requestId]
        else {
            return
        }

        let data = json["data"]
        if let data = data {
            completition!(data as? Json)
        } else {
            completition!(nil)
        }
        refetchOrderRequests.removeValue(forKey: requestId)
    }

    private func refetchOrder(completition: @escaping ([String: Any]?) -> Void) {
        // creates a unique id that will be used as a key of the refetchOrderRequests dictionary
        refetchOrderRequestId += 1
        refetchOrderRequests[refetchOrderRequestId] = completition

        /// the js refetchOrder functions returns a promise but  evaluateJavaScript(Swift) does not support async or then for js promises
        ///  so we need to use a local post message to retrive the value returned by refetchOrder (JS)
        let js = """
        (function() {
            function refetchOrder( callback) {
                deunaRefetchOrder()
                    .then(data => {
                        callback({type:"refetchOrder", data: data , requestId: \(refetchOrderRequestId) });
                    })
                    .catch(error => {
                        callback({type:"refetchOrder", data: null , requestId: \(refetchOrderRequestId) });
                    });
            }

            refetchOrder(function(result) {
                window.webkit.messageHandlers.refetchOrder.postMessage(JSON.stringify(result));
            });
        })();
        """
        webView?.evaluateJavaScript(js)
    }
}
