import UIKit
@preconcurrency import WebKit

class BaseWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    let openRequestNavigationsInNewTab: Bool
    public var webView: WKWebView?
    private var delegate: DeunaWebViewDelegate?
    
    init(openRequestNavigationsInNewTab: Bool) {
        self.openRequestNavigationsInNewTab = openRequestNavigationsInNewTab
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var deunaDelegate: DeunaWebViewDelegate? {
        set {
            delegate = newValue
            webView?.navigationDelegate = self
            webView?.uiDelegate = self
        }
        get {
            return delegate
        }
    }
    
    /// Listen when url content is loaded
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.onWebViewLoaded()
    }
    
    /// Listen window.open
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures)
        -> WKWebView?
    {
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        if url.isFileDownloadUrl {
            delegate?.onDownloadFile(url)
        } else {
            delegate?.onOpenInNewTab(url)
        }
        return nil
    }
    
    /// Listen webview url navigations
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        if url.isFileDownloadUrl {
            decisionHandler(.cancel)
            delegate?.onDownloadFile(url)
            return
        }
        
        if keysForExternalUrls.contains(where: { url.absoluteString.contains($0) }) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            delegate?.onOpenInNewTab(url)
            return
        }
        
        guard openRequestNavigationsInNewTab else {
            decisionHandler(.allow)
            return
        }
        
        let isExternalUrl = navigationAction.targetFrame == nil
        
        if isExternalUrl {
            decisionHandler(.cancel)
            delegate?.onOpenInNewTab(url)
        } else {
            decisionHandler(.allow)
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
        delegate?.onWebviewError(error._code)
    }
}

protocol DeunaWebViewDelegate {
    func onWebViewLoaded()
    
    func onWebviewError(_ errorCode: Int)
    
    func onOpenInNewTab(_ url: URL)
    
    func onDownloadFile(_ url: URL)
}
