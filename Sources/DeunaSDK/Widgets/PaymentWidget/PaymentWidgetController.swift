
import WebKit

class PaymentWidgetViewController: DeunaWebViewController {
    let callbacks: PaymentWidgetCallbacks
    let widgetConfig: WidgetConfig
    
    init(
        callbacks: PaymentWidgetCallbacks,
        hidePayButton: Bool? = false,
        isEmbeddedWidget: Bool? = false,
        widgetConfig: WidgetConfig
    ) {
        self.callbacks = callbacks
        self.widgetConfig = widgetConfig
        super.init(hidePayButton: hidePayButton, isEmbeddedWidget: isEmbeddedWidget)
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
        guard controller.allowPostMessageHandler(didReceive: message) else {
            return
        }
       
        guard let messageData = controller.getMessageData(message: message) else {
            return
        }
        
        handleEventData(message: messageData)
    }
}
