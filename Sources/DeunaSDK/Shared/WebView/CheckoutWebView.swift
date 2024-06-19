//
//  CheckoutWebView.swift
//
//
//  Created by Darwin on 6/3/24.
//

import Foundation
import WebKit


/// A view controller for handling the checkout process.
class CheckoutViewController: BaseWebViewController, WKScriptMessageHandler {
    let callbacks: CheckoutCallbacks
    private let closeEvents: Set<CheckoutEvent>

    /// Initializes the checkout view controller with the provided callbacks and close events.
    ///
    /// - Parameters:
    ///   - callbacks: The callbacks to handle checkout events.
    ///   - closeEvents: Set of events that trigger the checkout to close.
    init(callbacks: CheckoutCallbacks, closeEvents: Set<CheckoutEvent>) {
        self.callbacks = callbacks
        self.closeEvents = closeEvents
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add self as message handler for handling JavaScript messages
        configuration.userContentController.add(self, name: "deuna")
    }
    
    override func onLoadError() {
        // Notify error callback if checkout initialization fails
        let error = CheckoutError(type: .checkoutInitializationFailed)
        callbacks.onError?(error)
    }

    /// Handler for receiving JavaScript messages.
    ///
    /// - Parameters:
    ///   - userContentController: The user content controller.
    ///   - message: The message received.
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let jsonData = getMessageData(message: message) else {
            return
        }

        do {
            // Decode the JSON message into CheckoutResponse
            let decoder = JSONDecoder()
            let eventData = try decoder.decode(CheckoutResponse.self, from: jsonData)
            callbacks.eventListener?(eventData.type, eventData)

            // Invoke appropriate callbacks based on event type
            switch eventData.type {
            case .apmSuccess, .purchase:
                callbacks.onSuccess?(eventData)
            case .paymentMethods3dsInitiated:
                threeDsAuth = true
            case .apmClickRedirect:
                // No action required for these events
                break
            case .purchaseRejected, .linkFailed, .purchaseError:
                // Handle errors related to purchase or payment
                let metadata = eventData.data.metadata
                let errorType: CheckoutErrorType = (metadata != nil) ? .paymentError : .unknownError
                let error = CheckoutError(type: errorType, order: eventData.data.order)
                callbacks.onError?(error)
            case .linkClose:
                callbacks.onCanceled?()
                closeWebView()
            default:
                DeunaLogs.debug("Received unknown event type: \(eventData.type)")
            }
            
            // Close the checkout web view if the received event type is in the closeEvents set
            if self.closeEvents.contains(eventData.type) {
                self.closeWebView()
            }

        } catch {
            DeunaLogs.warning(error.localizedDescription)
        }
    }
}
