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

/// A base view controller for handling web views.
class BaseWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private var loaderVisible = true
    private var activityIndicator: UIActivityIndicatorView!
    let configuration = WKWebViewConfiguration()
    private var webView: WKWebView?
    public var closeWebviewWasCalled = false
    public var threeDsAuth = false

    private var subWebViewController: SubWebViewController? = nil

    /// The source code for injecting JavaScript to override window.open behavior.
    var scriptSource = """
    window.open = function(open) {
        return function(url, name, features) {
            location.href = url; // or window.location.replace(url)
        };
    }(window.open);
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
        guard !self.loaderVisible else {
            return
        }
        self.activityIndicator.removeFromSuperview()
        self.loaderVisible = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        view.addSubview(webView)
        self.hideLoader() // Called when the URL has finished loading completely
        self.adjustScrolling(webView: webView)
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
                return
            }
            if url.absoluteString.contains("view_challenge") || self.threeDsAuth == true {
                decisionHandler(.cancel)
                self.threeDsAuth = false
                // load the url in a new webview
                self.subWebViewController = SubWebViewController(
                    url: url,
                    onLoadError: {
                        self.onLoadError()
                    }
                )
                self.subWebViewController?.modalPresentationStyle = .overFullScreen
                self.present(self.subWebViewController!, animated: false)
                return
            }
        }

        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        decisionHandler(.allow)
    }

    /// Adjusts scrolling based on content height.
    ///
    /// - Parameter webView: The web view.
    private func adjustScrolling(webView: WKWebView) {
        webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { result, _ in
           if let contentHeight = result as? CGFloat, contentHeight > self.view.bounds.height {
               webView.scrollView.isScrollEnabled = true
           } else {
               webView.scrollView.isScrollEnabled = false
           }
        })
    }

    /// Dismisses the web view controller.
    func closeWebView() {
        self.subWebViewController?.close()
        dismiss(animated: true)
        self.closeWebviewWasCalled = true
    }

    /// Gets the data from the script message as Foundation Data.
    ///
    /// - Parameter message: The script message.
    /// - Returns: The data from the script message, if available.
    func getMessageData(message: WKScriptMessage) -> Foundation.Data? {
        guard let jsonString = message.body as? String else {
            return nil
        }
        return jsonString.data(using: .utf8)
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
        self.onLoadError()
    }

    func onLoadError() {}
}
