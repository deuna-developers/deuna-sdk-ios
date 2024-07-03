
import WebKit

class PaymentWidgetViewController: BaseWebViewController, WKScriptMessageHandler {
    let callbacks: PaymentWidgetCallbacks
    
    var refetchOrderRequestId = 0
    
    /// dictionary to save the refetch order requests
    var refetchOrderRequests: [Int: ((RefetchedOrder?) -> Void)?] = [:]

    init(callbacks: PaymentWidgetCallbacks) {
        self.callbacks = callbacks
        super.init()
        
        // Define the JS xprops callbacks to be compatible with the payment link
        // that uses zoid to notify the messages
        let xpropsScript = WKUserScript(
            source: """
            console.log = function(message) {
                window.webkit.messageHandlers.consoleLog.postMessage(message);
            };
            
            window.xprops = {
                onEventDispatch : function (event) {
                    window.webkit.messageHandlers.xprops.postMessage(JSON.stringify(event));
                },
                onCustomCssSubscribe: function (setCustomCSS)  {
                    window.setCustomCss = setCustomCSS;
                },
                onRefetchOrderSubscribe: function (refetchOrder) {
                    window.deunaRefetchOrder = refetchOrder;
                },
            };
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(xpropsScript)
        configuration.userContentController.add(self, name: "xprops")
        configuration.userContentController.add(self, name: "refetchOrder")
        configuration.userContentController.add(self, name: "consoleLog")
    }
    
    override func onLoadError() {
        // Notify error callback for any navigation failure
        callbacks.onError?(.unknownError)
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
       
        guard let jsonData = getMessageData(message: message) else {
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            
            guard json != nil else {
                return
            }
            
            let type = json!["type"] as? String
            let data = json!["data"] as? [String: Any]
            
            if type == PaymentWidgetEvent.onBinDetected.rawValue {
                guard data != nil else {
                    return
                }
                handleOnBinDetected(jsonMetadata: data!["metadata"] as? [String: Any])
                return
            }
            
            if type == PaymentWidgetEvent.onInstallmentSelected.rawValue {
                guard data != nil else {
                    return
                }
                handleOnInstallmentSelected(jsonMetadata: data!["metadata"] as? [String: Any])
                return
            }
            
            if type == PaymentWidgetEvent.refetchOrder.rawValue {
                handleOnRefetchOrder(json: json!)
                return
            }
            
            // Decode the JSON message into CheckoutResponse
            let decoder = JSONDecoder()
            let eventData = try decoder.decode(CheckoutResponse.self, from: jsonData)
            handleEventData(eventData: eventData)
        } catch {
            DeunaLogs.warning(error.localizedDescription)
        }
    }
    
    /// send the custom css  styles to the payment widget link
    func setCustomCss(data: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webView?.evaluateJavaScript("javascript:setCustomCss(\(jsonString),'*')")
            }
        } catch {
            DeunaLogs.error(error.localizedDescription)
        }
    }
}
