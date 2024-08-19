
import WebKit



class PaymentWidgetViewController: BaseWebViewController, WKScriptMessageHandler {
    let callbacks: PaymentWidgetCallbacks
    
    var refetchOrderRequestId = 0
    
    /// dictionary to save the refetch order requests
    var refetchOrderRequests: [Int: ((Json?) -> Void)?] = [:]

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
                onCustomStyleSubscribe: function (setCustomStyle)  {
                    window.setCustomStyle = setCustomStyle;
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
    
    override func onLoadError(code: Int, message: String) {
        // Notify error callback for any navigation failure
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
       
        guard let messageData = getMessageData(message: message) else {
            return
        }
        
        handleEventData(message: messageData)
    }
    
    /// send the custom css  styles to the payment widget link
    func setCustomCss(data: Json) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webView?.evaluateJavaScript("javascript:setCustomCss(\(jsonString),'*')")
            }
        } catch {
            DeunaLogs.error(error.localizedDescription)
        }
    }
    
    /// send the custom styles to the payment widget link
    func setCustomStyle(data: Json) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webView?.evaluateJavaScript("javascript:setCustomStyle(\(jsonString),'*')")
            }
        } catch {
            DeunaLogs.error(error.localizedDescription)
        }
    }
}
