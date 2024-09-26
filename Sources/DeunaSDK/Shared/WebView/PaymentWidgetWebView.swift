
import WebKit



class PaymentWidgetViewController: BaseWebViewController{
    let callbacks: PaymentWidgetCallbacks
    
    var refetchOrderRequestId = 0
    
    /// dictionary to save the refetch order requests
    var refetchOrderRequests: [Int: ((Json?) -> Void)?] = [:]

    init(callbacks: PaymentWidgetCallbacks) {
        self.callbacks = callbacks
        super.init()
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
        
        if message.name == WebViewUserContentControllerNames.refetchOrder {
            handleOnRefetchOrder(json: messageData.json)
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
    
    private func handleOnRefetchOrder(json: [String: Any]) {
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
    
    func refetchOrder(completition: @escaping ([String: Any]?) -> Void) {
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
                window.webkit.messageHandlers.\(WebViewUserContentControllerNames.refetchOrder).postMessage(JSON.stringify(result));
            });
        })();
        """
        webView?.evaluateJavaScript(js)
    }
}
