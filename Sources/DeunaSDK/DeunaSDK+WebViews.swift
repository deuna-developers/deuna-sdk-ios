//
//  DeunaSDK+WebViews.swift
//


import Foundation
import WebKit

extension DeunaSDK{
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            self.log("navigationAction \(navigationAction)")
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    
    @objc public func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url=navigationAction.request.url{
            self.log("Navigating to \(url) with \(navigationAction.navigationType) via \(String(describing: navigationAction.targetFrame))")
            if url.absoluteString.contains("view_challenge") || self.threeDsAuth==true{
                openInNewWebView(url: url)
                decisionHandler(.cancel)
                return
            }
        }
        
        if navigationAction.targetFrame == nil {
            self.log("Navigating in self frame")
            webView.load(navigationAction.request)
            decisionHandler(.allow)
            return
        }
        decisionHandler(.allow)
        return
    }
    
    
    @objc func openInNewWebView(url: URL) {
        self.subWebView = DeunaWebViewManager(parentView: self.DeunaView!, closeButtonConfig: self.closeButtonConfig)
        self.subWebView?.openInNewWebView(url: url, environment: DeunaSDK.shared.environment)
        // Schedule the closeWebView method to be called after 20 seconds
//       DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
//           self.closeSubWebView()
//       }
    }
    
    
    // MARK: - WKNavigationDelegate Methods
    @objc public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Display the close button when the WebView fails to load
        if self.showCloseButton{
            showCloseButtonInView()
        }
        self.log("Loading view failed",error: error)
        let error = DeUnaErrorMessage(message: "Loading view failed", type: .unknownError)
        callbacks.onError?(error)
        closeCheckout()
    }
    
    @objc public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Hide the loader and display the close button when the WebView finishes loading
        hideLoader()
        if self.showCloseButton{
            showCloseButtonInView()
        }
    }
}
