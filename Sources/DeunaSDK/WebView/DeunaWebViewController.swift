//
//  BaseWebviewController.swift
//
//
//  Created on 6/3/24.
//

import Foundation
import UIKit
@preconcurrency import WebKit

// Keywords to recognize a url that should be opened externally (safari)
let keysForExternalUrls = ["vapormicuenta"]

public typealias OnWidgetClosed = () -> Void

/// A base view controller for handling web views.
class DeunaWebViewController: BaseWebViewController, DeunaWebViewDelegate, WKScriptMessageHandler {

    var activityIndicator: UIActivityIndicatorView?
    let configuration = WKWebViewConfiguration()
    
    public var closeAction: CloseAction = .userAction
   
    public var onWidgetClosed: OnWidgetClosed? = nil
    
    // When this var is false the close feature is disabled
    public var dismissible = true
    
    var newTabWebViewController: NewTabWebViewController? = nil
    
    // Define the JS xprops callbacks to be compatible with the payment link
    // that uses zoid to notify the messages
    var scriptSource = """
    
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
        super.init(openRequestNavigationsInNewTab: true)
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
  
        injectJs()
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        deunaDelegate = self
        
        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               
        let request = URLRequest(url: url)
        webView?.load(request)
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
    
    
    /// function that can be override to listen when an error  is throw during the url loading
    func onLoadError(code: Int, message: String) {}

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
    
    func onWebViewLoaded() {
        view.addSubview(webView!)
        addDismissLineBar()
        // wait until url is loaded to set the webview height
        webView!.frame.size.height = view.frame.height
        view.translatesAutoresizingMaskIntoConstraints = false
        webView!.scrollView.isScrollEnabled = true
        hideLoader() // Called when the URL has finished loading completely
    }
    
    func onWebviewError(_ errorCode: Int) {
        onLoadError(
            code: errorCode,
            message: LoadUrlErrorMessages.getMessage(code: errorCode)
        )
    }
    
    func onOpenInNewTab(_ url: URL) {
        openInNewTab(urlString: url.absoluteString)
    }
    
    func onDownloadFile(_ url: URL) {}
    
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
