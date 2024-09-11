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
class BaseWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private var loaderVisible = true
    private var activityIndicator: UIActivityIndicatorView!
    let configuration = WKWebViewConfiguration()

    public var closeAction: CloseAction = .userAction
    public var threeDsAuth = false
    public var onWidgetClosed: OnWidgetClosed? = nil

    // When this var is false the close feature is disabled
    public var dismissible = true

    public var webView: WKWebView?

    private var subWebViewController: SubWebViewController? = nil

    // Define the JS xprops callbacks to be compatible with the payment link
    // that uses zoid to notify the messages
    var scriptSource = """
    window.open = function(open) {
        return function(url, name, features) {
            location.href = url; // or window.location.replace(url)
        };
    }(window.open);

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
        self.showLoader()
    }

    /// Loads the web view with the specified URL.
    ///
    /// - Parameter urlString: The URL string to load.
    func loadUrl(urlString: String) {
        let userScript = WKUserScript(
            source: scriptSource,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )

        self.configuration.preferences.javaScriptEnabled = true
        self.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        self.configuration.userContentController.addUserScript(userScript)
        self.webView = WKWebView(
            frame: view.bounds,
            configuration: self.configuration
        )
        self.webView!.navigationDelegate = self
        self.webView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            self.webView?.load(request)
        }
    }

    /// Shows the activity indicator loader.
    private func showLoader() {
        self.activityIndicator = UIActivityIndicatorView(style: .gray)
        self.activityIndicator.center = view.center
        view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }

    /// Hides the activity indicator loader.
    private func hideLoader() {
        guard self.loaderVisible else {
            return
        }
        self.activityIndicator.removeFromSuperview()
        self.loaderVisible = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        view.addSubview(webView)

        // wait until url is loaded to set the webview height
        webView.frame.size.height = view.frame.height
        view.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = true

        self.hideLoader() // Called when the URL has finished loading completely
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url {
            // Check if the url contains the declared keywords, if so,
            // open the url in Safari and not in the app's webview
            if let foundKeyword = keysForExternalUrls.first(where: { url.absoluteString.contains($0) }) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                DeunaLogs.info("foundKeyword \(foundKeyword)")
                return
            }
            
            /// check if the url request must be opened in a new web view (legal urls , 3ds auth)
            /// This is required due to if we open the url in the same web view we lost the post messages listeners
            let target = navigationAction.targetFrame
            let isMainFrame = target?.isMainFrame ?? false
            if target == nil ||  (isMainFrame && !self.loaderVisible) {
                decisionHandler(.cancel)
                self.subWebViewController = SubWebViewController(
                    url: url,
                    onLoadError: { code in
                        self.onLoadError(
                            code: code,
                            message: LoadUrlErrorMessages.getMessage(code: code)
                        )
                    }
                )
                self.subWebViewController?.modalPresentationStyle = target == nil ?  .pageSheet : .overFullScreen
                self.present(self.subWebViewController!, animated: false)
                return
            }
        }
        decisionHandler(.allow)
    }

    /// Closes the sub web view
    func closeSubWebViewController() {
        self.subWebViewController?.close()
        self.subWebViewController = nil
    }

    /// Dismisses the web view controller.
    func closeWebView(_ closeAction: CloseAction) {
        self.closeAction = closeAction
        self.closeSubWebViewController()
        dismiss(animated: true) {
            self.onWidgetClosed?()
        }
    }

    /// Gets the data from the script message as Foundation Data.
    ///
    /// - Parameter message: The script message.
    /// - Returns: The data from the script message, if available.
    func getMessageData(message: WKScriptMessage) -> Message? {
        do {
            guard let body = message.body as? String, let data = body.data(using: .utf8) else {
                return nil
            }

            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return nil
            }
            return Message(data: data, json: json)
        } catch {
            DeunaLogs.error(error.localizedDescription)
            return nil
        }
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
        self.onLoadError(
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
                self.webView?.evaluateJavaScript("javascript:postMessage(JSON.stringify(\(jsonString)),'*')")
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
        self.dismissible = enabled

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
                self.webView?.evaluateJavaScript("javascript:setCustomStyle(\(jsonString),'*')")
            }
        } catch {
            DeunaLogs.error(error.localizedDescription)
        }
    }
}
