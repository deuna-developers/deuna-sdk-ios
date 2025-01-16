//
//  CheckoutWebView.swift
//
//
//  Created by Darwin on 6/3/24.
//

import Foundation
import WebKit

/// A view controller for handling the checkout process.
class CheckoutViewController: DeunaWebViewController {
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
    }

    override func onLoadError(code: Int, message: String) {
        // Notify error callback if checkout initialization fails
        callbacks.onError?(
            PaymentsError(
                type: .errorWhileLoadingTheURL,
                metadata: PaymentsError.ErrorMetadata(
                    code: "\(code)",
                    message: message
                )
            )
        )
    }

    /// Handler for receiving JavaScript messages.
    ///
    /// - Parameters:
    ///   - userContentController: The user content controller.
    ///   - message: The message received.
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard allowPostMessageHandler(didReceive: message) else {
            return
        }
        
        guard let messageData = getMessageData(message: message) else {
            return
        }

        let json = messageData.json
        guard let type = json["type"] as? String, let data = json["data"] as? [String: Any] else {
            return
        }

        guard let event = CheckoutEvent(rawValue: type) else {
            DeunaLogs.debug("Received unknown event type: \(type)")
            return
        }

        callbacks.onEventDispatch?(event, data)

        // Invoke appropriate callbacks based on event type
        switch event {
        case .purchase:
            closeSubWebViewController()
            callbacks.onSuccess?(data["order"] as! Json)
        case .apmClickRedirect:
            // No action required for these events
            break
        case .purchaseError:
            closeSubWebViewController()
            // Handle errors related to purchase or payment
            if let error = PaymentsError.fromJson(data: data) {
                callbacks.onError?(error)
            }
        case .linkClose:
            closeWebView(.userAction)
        default:
            DeunaLogs.debug("Received unknown event type: \(event)")
        }

        // Close the checkout web view if the received event type is in the closeEvents set
        if closeEvents.contains(event) {
            closeWebView(.systemAction)
        }
    }
}
