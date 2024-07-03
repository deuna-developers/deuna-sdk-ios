//
//  File.swift
//
//
//  Created by Darwin Morocho on 28/3/24.
//

import Foundation
import WebKit

class SubWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let url: URL
    private let onLoadError: () -> Void
    private var webView: WKWebView? = nil
    private let configuration = WKWebViewConfiguration()
    
    public var autoClosed =  false

    init(url: URL, onLoadError: @escaping () -> Void) {
        self.url = url
        self.onLoadError = onLoadError
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
        self.configuration.preferences.javaScriptEnabled = true
        self.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        self.webView = WKWebView(frame: view.bounds, configuration: self.configuration)
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
        self.onLoadError()
    }
    
    func close(){
        autoClosed = true
        dismiss(animated: false)
    }
}
