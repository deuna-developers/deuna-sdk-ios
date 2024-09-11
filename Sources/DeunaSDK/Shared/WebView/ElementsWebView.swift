//
//  ElementsWebView.swift
//
//
//  Created on 6/3/24.
//

import Foundation
import WebKit

/// A view controller for handling the elements process.
class ElementsViewController: BaseWebViewController, WKScriptMessageHandler {
    let callbacks: ElementsCallbacks
    private let closeEvents: Set<ElementsEvent>

    /// Initializes the elements view controller with the provided callbacks and close events.
    ///
    /// - Parameters:
    ///   - callbacks: The callbacks to handle elements events.
    ///   - closeEvents: Set of events that trigger the elements process to close.
    init(callbacks: ElementsCallbacks, closeEvents: Set<ElementsEvent>) {
        self.callbacks = callbacks
        self.closeEvents = closeEvents
        super.init()
        configuration.userContentController.add(self, name: "deuna")
        configuration.userContentController.add(self, name: "xprops")
        configuration.userContentController.add(self, name: "consoleLog")
    }

    override func onLoadError(code: Int, message: String) {
        // Notify error callback for any navigation failure
        let error = ElementsError(type: .unknownError)
        self.callbacks.onError?(error)
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
        if message.name == "consoleLog" {
            if let messageBody = message.body as? String {
                DeunaLogs.debug("JavaScript console.log: \(messageBody)")
            }
            return
        }
        
        // Attempt to decode the received JSON message
        guard let messageData = getMessageData(message: message) else {
            return
        }

        let json = messageData.json
        guard let type = json["type"] as? String, let data = json["data"] as? [String: Any] else {
            return
        }

        guard let event = ElementsEvent(rawValue: type) else {
            DeunaLogs.debug("Received unknown event type: \(type)")
            return
        }

        guard messageData.json["type"] as? String != ElementsError.ErrorType.vaultFailed.rawValue else {
            if let error = ElementsError.fromJson(type: .vaultFailed, data: data) {
                self.callbacks.onError?(error)
            }
            return
        }

        // Decode the JSON message into ElementsResponse
        self.callbacks.onEventDispatch?(event, data)

        // Invoke appropriate callbacks based on event type
        switch event {
        case .vaultSaveSuccess, .cardSuccessfullyCreated:
            closeSubWebViewController()
            self.callbacks.onSuccess?(data)
        case .vaultSaveError:
            closeSubWebViewController()
            if let error = ElementsError.fromJson(type: .vaultSaveError, data: data) {
                self.callbacks.onError?(error)
            }
        case .vaultClickRedirect3DS:
            threeDsAuth = true
        case .vaultClosed:
            // Close the elements web view
            closeWebView(.userAction)
        default:
            break
        }

        // Close the elements web view if the received event type is in the closeEvents set
        if self.closeEvents.contains(event) {
            self.closeWebView(.systemAction)
        }
    }
}
