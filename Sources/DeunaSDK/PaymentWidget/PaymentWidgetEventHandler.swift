//
//  PaymentWidgetEventHandler.swift
//
//
//  Created by deuna on 27/6/24.
//

import Foundation
import WebKit

extension PaymentWidgetViewController {
    public func handleEventData(eventData: CheckoutResponse) {
        // Invoke appropriate callbacks based on event type
        switch eventData.type {
        case .apmSuccess, .purchase:
            callbacks.onSuccess?(eventData.data)
        case .paymentMethods3dsInitiated:
            threeDsAuth = true
        case .apmClickRedirect:
            // No action required for these events
            break
        case .purchaseRejected, .linkFailed, .purchaseError:
            // Handle errors related to purchase or payment
            let metadata = eventData.data.metadata
            let errorType: PaymentWidgetsErrorType = (metadata != nil) ? .paymentError : .unknownError
            callbacks.onError?(errorType)
        case .linkClose:
            callbacks.onCanceled?()
            closeWebView()
        default:
            break
        }
    }

    func handleOnBinDetected(jsonMetadata: [String: Any]?) {
        guard jsonMetadata != nil else {
            callbacks.onCardBinDetected?(nil, refetchOrder)
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonMetadata!, options: [])
            let decoder = JSONDecoder()
            let metadata = try decoder.decode(CardBinMetadata.self, from: jsonData)
            callbacks.onCardBinDetected?(metadata, refetchOrder)
        } catch {
            DeunaLogs.error(error.localizedDescription)
        }
    }

    func handleOnInstallmentSelected(jsonMetadata: [String: Any]?) {
        guard  jsonMetadata != nil && jsonMetadata?["plan_option_id"] != nil else {
            callbacks.onInstallmentSelected?(nil, refetchOrder)
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonMetadata!, options: [])
            let decoder = JSONDecoder()
            let metadata = try decoder.decode(InstallmentMetadata.self, from: jsonData)
            callbacks.onInstallmentSelected?(metadata, refetchOrder)
        } catch {
            DeunaLogs.error(error.localizedDescription)
        }
    }

    func handleOnRefetchOrder(json: [String: Any]) {
        guard let requestId = json["requestId"] as? Int,
              let completition = refetchOrderRequests[requestId]
        else {
            return
        }

        do {
            let data = json["data"]
            if let data = data {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let decoder = JSONDecoder()
                let order = try decoder.decode(RefetchedOrder.self, from: jsonData)
                completition!(order)
            } else {
                completition!(nil)
            }
        } catch {
            print(error.localizedDescription)
            completition!(nil)
        }
        refetchOrderRequests.removeValue(forKey: requestId)
    }

    private func refetchOrder(completition: @escaping (RefetchedOrder?) -> Void) {
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
