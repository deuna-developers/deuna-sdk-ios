//
//  DeunaSDK+WebViews.swift
//


import Foundation
import WebKit

// Keywords to recognize a url that should be opened externally (safari)
let keysForExternalUrls = ["vapormicuenta"]

extension DeunaSDK{
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            self.log("WebView: \(webView == DeunaWebView ? "DeunaWebView" : "DeunaElementsWebView") - Navigation Action: \(navigationAction)")
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
            
            // Check if the url contains the declared keywords, if so, open the url in Safari and not in the app's webview
            if let foundKeyword = keysForExternalUrls.first(where: { url.absoluteString.contains($0) }) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
            
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
        self.subWebView = DeunaWebViewManager(parentView: self.DeunaView!)
        self.subWebView?.openInNewWebView(url: url, environment: DeunaSDK.shared.environment)
    }
    
    
    // MARK: - WKNavigationDelegate Methods
    @objc public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Display the close button when the WebView fails to load
        self.log("Loading view failed",error: error)
        let error = DeUnaErrorMessage(message: "Loading view failed", type: .unknownError)
        callbacks.onError?(error)
        closeCheckout()
    }
    
    @objc public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Hide the loader and display the close button when the WebView finishes loading
        hideLoader()
    }
}
