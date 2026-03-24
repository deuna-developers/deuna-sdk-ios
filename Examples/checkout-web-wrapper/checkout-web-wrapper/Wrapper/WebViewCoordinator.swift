import Foundation
@preconcurrency import WebKit

/// `WebViewCoordinator` acts as the delegate for `WKWebView`, handling navigation events
/// and processing messages sent from the web content.
class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    // MARK: - Properties

    /// An closure to handle external URLs.
    /// This allows injecting the URL opening logic from outside,
    /// improving flexibility and testability.
    let onExternalURLOpened: (URL) -> Void

    /// An closure to handle messages received from the web content.
    /// This decouples message processing logic from the coordinator.
    let onJavaScriptMessageReceived: (JavaScriptMessage) -> Void

    init(
        onExternalURLOpened: @escaping (URL) -> Void,
        onJavaScriptMessageReceived: @escaping (JavaScriptMessage) -> Void
    ) {
        self.onExternalURLOpened = onExternalURLOpened
        self.onJavaScriptMessageReceived = onJavaScriptMessageReceived
    }

    // MARK: - WKNavigationDelegate

    /// Decides whether a navigation action should be allowed or canceled.
    ///
    /// This method is used to intercept navigations originating from link clicks
    /// and redirect them to an external handler (like Safari View Controller)
    /// while preventing navigation within the `WKWebView`.
    ///
    /// - Parameters:
    ///   - webView: The web view performing the navigation.
    ///   - navigationAction: The `WKNavigationAction` object describing the navigation.
    ///   - decisionHandler: The closure to call with the navigation decision policy.
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        // Check if the navigation action is a link activation and if it has a URL.
        guard navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url else {
            // If it's not a link activation or has no URL, allow normal navigation.
            decisionHandler(.allow)
            return
        }

        onExternalURLOpened(url)

        // Cancel the navigation within the WKWebView since the URL will be opened externally.
        decisionHandler(.cancel)
    }
    
    
    // MARK: - WKNavigationDelegate
    
    /// Listen window.open
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    )
        -> WKWebView?
    {
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        onExternalURLOpened(url)
        return nil
    }

    // MARK: - WKScriptMessageHandler

    /// Processes messages received from the web content.
    ///
    /// This method is invoked when the web content (via JavaScript)
    /// sends a message to the native application using `window.webkit.messageHandlers.<name>.postMessage()`.
    ///
    /// - Parameters:
    ///   - userContentController: The user content controller associated with the web view.
    ///   - message: The `WKScriptMessage` object containing the handler name and the message body.
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if message.name == "deunaPayment" {
            guard let bodyString = message.body as? String, let jsonData = bodyString.data(using: .utf8) else {
                return
            }

            do {
                let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

                guard let json = json,
                      let callbackName = json["callbackName"] as? String,
                      let widgetType = json["widgetType"] as? String,
                      let payload = json["data"] as? [String: Any]
                else {
                    return
                }

                guard let callbackName = CallbackName(rawValue: callbackName),
                      let widgetType = WidgetType(rawValue: widgetType) else {
                    return
                }

                onJavaScriptMessageReceived(
                    JavaScriptMessage(
                        callbackName: callbackName,
                        payload: payload,
                        widgetType: widgetType
                    )
                )
            }
        }
    }
}
