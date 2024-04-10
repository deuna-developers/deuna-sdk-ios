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
    }
    
    override func onLoadError() {
        // Notify error callback for any navigation failure
        let error = ElementsError(type: .unknownError)
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
        // Attempt to decode the received JSON message
        guard let jsonData = getMessageData(message: message) else {
            return
        }

        do {
            // Decode the JSON message into ElementsResponse
            let decoder = JSONDecoder()
            let eventData = try decoder.decode(ElementsResponse.self, from: jsonData)
            
   
            self.callbacks.eventListener?(eventData.type, eventData)

            // Invoke appropriate callbacks based on event type
            switch eventData.type {
            case .vaultSaveSuccess, .cardSuccessfullyCreated:
                self.callbacks.onSuccess?(eventData)
            case .vaultFailed, .vaultSaveError:
                DeunaLogs.warning(eventData.data.metadata?.errorMessage ?? "")
                // Handle errors related to saving elements
                let errorDeuna = ElementsError(type: .vaultSaveError)
                self.callbacks.onError?(errorDeuna)
            case .vaultClickRedirect3DS:
                threeDsAuth = true
            case .vaultClosed:
                // Close the elements web view
                callbacks.onCanceled?()
                closeWebView()
            default:
                DeunaLogs.debug("Received unknown event type: \(eventData.type)")
            }

            // Close the elements web view if the received event type is in the closeEvents set
            if self.closeEvents.contains(eventData.type) {
                self.closeWebView()
            }
        } catch {
            DeunaLogs.warning(error.localizedDescription)
        }
    }
}
