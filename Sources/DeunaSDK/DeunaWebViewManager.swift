//
//  DeunaWebViewManager.swift
//

import UIKit
import WebKit

class DeunaWebViewManager: NSObject, WKNavigationDelegate, WKUIDelegate {
    
    var webView: WKWebView?
    var parentView: UIView // The view to add the new web view to
    var closeButtonConfig: CloseButtonConfig?
    private let closeButtonTag = 4342
    init(parentView: UIView, closeButtonConfig: CloseButtonConfig?) {
        self.parentView = parentView
        if closeButtonConfig != nil {
            self.closeButtonConfig = closeButtonConfig!
        }
    }
    
    @objc func openInNewWebView(url: URL, environment: Environment) {
        print("Opening new view \(url)")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "deuna_sub_view")
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // Create a new instance of WKWebView
        webView = WKWebView(frame: parentView.bounds, configuration: configuration)
        
        webView?.navigationDelegate = self
        webView?.uiDelegate = self // If you need to implement WKUIDelegate methods
        webView?.backgroundColor = .clear
        webView?.isOpaque = true
        
        if environment == .development {
            if webView!.responds(to: Selector(("setInspectable:"))) {
                webView!.perform(Selector(("setInspectable:")), with: true)
            }
        }
        
        parentView.addSubview(webView!)
        webView?.load(URLRequest(url: url))
    }
    
    
    @objc func closeSubWebView(){
        webView?.removeFromSuperview()
        webView = nil
    }

    private func createCloseButton() -> UIButton {
        // Create the close button using the provided configuration or the default one
        let defaultConfig = CloseButtonConfig()
        let config = closeButtonConfig ?? defaultConfig
        
        let button = UIButton(frame: config.frame)
        button.setTitle(config.title, for: .normal)
        button.setTitleColor(config.titleColor, for: .normal)
        button.backgroundColor = config.backgroundColor
        button.addTarget(self, action: #selector(closeSubWebView), for: .touchUpInside)
        return button
    }
    
    private func showCloseButtonInView() {
        let closeButton = self.createCloseButton()
        closeButton.tag = closeButtonTag  // Set the tag
        self.webView?.addSubview(closeButton)
        self.webView?.bringSubviewToFront(closeButton)
    }
}

extension DeunaWebViewManager: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Handle the message received from the web content here
    }
}
