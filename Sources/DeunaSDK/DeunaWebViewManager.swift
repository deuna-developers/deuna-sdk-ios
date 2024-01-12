//
//  DeunaWebViewManager.swift
//

import UIKit
import WebKit

class DeunaWebViewManager: NSObject, WKNavigationDelegate, WKUIDelegate {
    var webView: WKWebView?
    var parentView: UIView
     
    init(parentView: UIView) {
        self.parentView = parentView
    }
    
    private func adjustScrolling(webView: WKWebView) {
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (result, error) in
            if let contentHeight = result as? CGFloat, contentHeight > webView.bounds.height {
                webView.scrollView.isScrollEnabled = true
            } else {
                webView.scrollView.isScrollEnabled = false
            }
        })
    }

    // Implementación del WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        adjustScrolling(webView: webView)
    }
    
    
    func openInNewWebView(url: URL, environment: Environment) {
        print("Opening new view \(url)")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "deuna_sub_view")
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webView = WKWebView(frame: parentView.bounds, configuration: configuration)
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        webView?.scrollView.isScrollEnabled = false
        webView?.scrollView.bounces = false
        webView?.backgroundColor = .white
        webView?.isOpaque = false
        
        if environment == .development {
            if webView!.responds(to: Selector(("setInspectable:"))) {
                webView!.perform(Selector(("setInspectable:")), with: true)
            }
        }
        
        parentView.addSubview(webView!)

        webView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView!.topAnchor.constraint(equalTo: parentView.topAnchor),
            webView!.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            webView!.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            webView!.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
        
        webView?.load(URLRequest(url: url))
    }
    
    
    @objc func closeSubWebView() {
        webView?.removeFromSuperview()
        webView = nil
    }
}

extension DeunaWebViewManager: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Handle the message received from the web content here
    }
}
