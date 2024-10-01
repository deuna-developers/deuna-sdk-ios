//
//  File.swift
//
//
//  Created by Darwin Morocho on 28/3/24.
//

import Foundation
import WebKit

class SubWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler  {
    
    
    private let url: URL
    private let onLoadError: (Int) -> Void
    private let onViewDestroyed: () -> Void
    
    private var webView: WKWebView? = nil
    private let configuration = WKWebViewConfiguration()

    init(url: URL, onLoadError: @escaping (Int) -> Void, onViewDestroyed: @escaping () -> Void) {
        self.url = url
        self.onLoadError = onLoadError
        self.onViewDestroyed = onViewDestroyed
        // Call super.init to initialize UIViewController first
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        self.loadUrl()
    }

    private func loadUrl() {
        
        let userScript = WKUserScript(
            source: """
            window.close = function() {
                window.webkit.messageHandlers.\(WebViewUserContentControllerNames.closeWindow).postMessage("");
            };
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.closeWindow)
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.userContentController.addUserScript(userScript)
        
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        view.addSubview(self.webView!)
        self.webView!.navigationDelegate = self

        let request = URLRequest(url: url)
        self.webView?.load(request)
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
        self.onLoadError(error._code)
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
        // wait until url is loaded to set the webview height
        webView.frame.size.height = view.frame.height
        view.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = true
        addDismissLineBar()
    }

    func close() {
        dismiss(animated: false)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        // Closed the current UIViewController when window.close is called
        if message.name == WebViewUserContentControllerNames.closeWindow {
            close()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.removeFromSuperview()
        webView?.stopLoading()
        webView = nil
        onViewDestroyed()
        super.viewDidDisappear(animated)
    }
    
    
}
