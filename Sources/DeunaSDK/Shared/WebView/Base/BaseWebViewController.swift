//
//  BaseWebviewController.swift
//
//
//  Created on 6/3/24.
//

import Foundation
import UIKit
import WebKit

// Keywords to recognize a url that should be opened externally (safari)
let keysForExternalUrls = ["vapormicuenta"]

public typealias OnWidgetClosed = () -> Void

/// A base view controller for handling web views.
class BaseWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    private var loaderVisible = true
    private var activityIndicator: UIActivityIndicatorView!
    let configuration = WKWebViewConfiguration()
    
    public var closeAction: CloseAction = .userAction
    public var threeDsAuth = false
    private var externalUrl: String? = nil
    public var onWidgetClosed: OnWidgetClosed? = nil
    
    // When this var is false the close feature is disabled
    public var dismissible = true
    
    public var webView: WKWebView?
    
    private var subWebViewController: SubWebViewController? = nil
    
    // Define the JS xprops callbacks to be compatible with the payment link
    // that uses zoid to notify the messages
    var scriptSource = """
    window.open = function(url, target, features) {
        window.webkit.messageHandlers.\(WebViewUserContentControllerNames.openInNewTab).postMessage(url);
        return window.open(url, target, features);
    };
    
    console.log = function(message) {
        window.webkit.messageHandlers.\(WebViewUserContentControllerNames.consoleLog).postMessage(message);
    };
    
    window.xprops = {
        onEventDispatch : function (event) {
            window.webkit.messageHandlers.\(WebViewUserContentControllerNames.xprops).postMessage(JSON.stringify(event));
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
    """
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        showLoader()
        addDismissLineBar()
    }
    
    /// Loads the web view with the specified URL.
    ///
    /// - Parameter urlString: The URL string to load.
    func loadUrl(urlString: String) {
        guard let url = URL(string: urlString) else {
            onLoadError(code: -1, message: "Invalid URL string")
            return
        }
        
        let userScript = WKUserScript(
            source: scriptSource,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.deuna)
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.xprops)
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.consoleLog)
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.refetchOrder)
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.openInNewTab)
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.saveBase64Image)
        
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.userContentController.addUserScript(userScript)
        
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        guard let webView = webView else { return }
               
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    /// Shows the activity indicator loader.
    func showLoader() {
        loaderVisible = true
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    /// Hides the activity indicator loader.
    func hideLoader() {
        guard loaderVisible else { return }
        activityIndicator.removeFromSuperview()
        loaderVisible = false
    }
    
    private func addDismissLineBar() {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.frame = CGRect(
            x: Int(view.frame.width * 0.5) - 40,
            y: 0,
            width: 80,
            height: 30
        )
        
        let lineBarHeight = 6
        let lineBar = UIView()
        lineBar.backgroundColor = .lightGray
        lineBar.frame = CGRect(
            x: Int(view.frame.width * 0.5) - 20,
            y: 10,
            width: 40,
            height: lineBarHeight
        )
        lineBar.layer.cornerRadius = 3
        view.addSubview(containerView)
        view.addSubview(lineBar)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        view.addSubview(webView)
        addDismissLineBar()
        // wait until url is loaded to set the webview height
        webView.frame.size.height = view.frame.height
        view.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = true
        hideLoader() // Called when the URL has finished loading completely
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        if keysForExternalUrls.contains(where: { url.absoluteString.contains($0) }) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            presentSubWebViewController(urlString: url.absoluteString)
            return
        }
        
        handleInternalUrl(navigationAction: navigationAction, decisionHandler: decisionHandler, url: url)
    }
    
    /// Handler for receiving JavaScript messages.
    ///
    /// - Parameters:
    ///   - userContentController: The user content controller.
    ///   - message: The message received.
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {}
    
    /// Handle post messages
    func allowPostMessageHandler(
        didReceive message: WKScriptMessage
    ) -> Bool {
        guard let messageBody = message.body as? String else {
            return false
        }
        
        switch message.name {
        case WebViewUserContentControllerNames.openInNewTab:
            presentSubWebViewController(urlString: messageBody)
            return false
        case WebViewUserContentControllerNames.consoleLog:
            return false
        case WebViewUserContentControllerNames.saveBase64Image:
            Base64ImageDownloader(messageBody, viewController: self).save()
            return false
        default:
            return true
        }
    }
    
    // 3Ds or payment redirections
    private func handleInternalUrl(
        navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void,
        url: URL
    ) {
        let isExternalUrl = navigationAction.targetFrame == nil
        
        if isExternalUrl {
            decisionHandler(.cancel)
            presentSubWebViewController(urlString: url.absoluteString)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func presentSubWebViewController(urlString: String) {
        if externalUrl != nil { return }
        externalUrl = urlString
        
        subWebViewController = SubWebViewController(
            url: URL(string: urlString)!,
            onLoadError: { [weak self] code in
                self?.onLoadError(
                    code: code,
                    message: LoadUrlErrorMessages.getMessage(code: code)
                )
            },
            onViewDestroyed: { [weak self] in
                self?.externalUrl = nil
            }
        )
        
        subWebViewController?.modalPresentationStyle = .pageSheet
        if let subWebVC = subWebViewController {
            present(subWebVC, animated: false)
        }
    }
    
    /// Closes the sub web view
    func closeSubWebViewController() {
        subWebViewController?.close()
        subWebViewController = nil
    }
    
    /// Dismisses the web view controller.
    func closeWebView(_ closeAction: CloseAction) {
        self.closeAction = closeAction
        dismiss(animated: true)
    }
    
    /// Gets the data from the script message as Foundation Data.
    ///
    /// - Parameter message: The script message.
    /// - Returns: The data from the script message, if available.
    func getMessageData(message: WKScriptMessage) -> Message? {
        guard
            let body = message.body as? String,
            let data = body.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else {
            return nil
        }
        return Message(data: data, json: json)
    }
    
    /// Handler for failed provisional navigation.
    ///
    /// - Parameters:
    ///   - webView: The web view.
    ///   - navigation: The navigation object.
    ///   - error: The error that occurred.
    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        onLoadError(
            code: error._code,
            message: LoadUrlErrorMessages.getMessage(code: error._code)
        )
    }
    
    /// function that can be override to listen when an error  is throw during the url loading
    func onLoadError(code: Int, message: String) {}
    
    /// send a JSON through javascript postMessage
    public func postMessage(json: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webView?.evaluateJavaScript("javascript:postMessage(JSON.stringify(\(jsonString)),'*')")
            }
        } catch {
            DeunaLogs.error(error.localizedDescription)
        }
    }
    
    /// class to store the post message data
    public class Message {
        let data: Foundation.Data
        let json: [String: Any]
        
        init(data: Foundation.Data, json: [String: Any]) {
            self.data = data
            self.json = json
        }
    }
    
    /// Configures whether the modal close action is enabled or disabled
    /// - Parameter enabled: A boolean value indicating if the modal close action should be enabled (`true`) or disabled (`false`)
    public func setCloseEnabled(_ enabled: Bool) {
        // Sets whether the modal is dismissible
        dismissible = enabled
        
        // On iOS 13.0 or later, configures whether the modal is locked on the screen
        if #available(iOS 13.0, *) {
            isModalInPresentation = !enabled
        }
    }
    
    /// Send the custom styles to the widget link
    public func setCustomStyle(data: Json) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webView?.evaluateJavaScript("javascript:setCustomStyle(\(jsonString),'*')")
            }
        } catch {
            DeunaLogs.error(error.localizedDescription)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        closeSubWebViewController()
        // Clean up the WKWebView when the view controller is destroyed
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.removeFromSuperview()
        webView?.stopLoading()
        webView = nil
        onWidgetClosed?()
    }
}
