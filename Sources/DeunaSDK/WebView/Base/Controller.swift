//
//  Controller.swift
//  DeunaSDK
//
//  Created by deuna on 9/4/25.
//

import Foundation
@preconcurrency import WebKit

protocol DeunaWebViewDelegate {
    func onWebViewLoaded()
    
    func onWebviewError(_ errorCode: Int)
    
    func onOpenInNewTab(_ url: URL)
    
    func onDownloadFile(_ url: URL)
}




class WebViewController: NSObject, WKNavigationDelegate, WKUIDelegate {
  
    let openRequestNavigationsInNewTab: Bool
    
    private var delegate: DeunaWebViewDelegate?
    var webView: WKWebView?
    
    var remoteFunctionsRequestId = 0
    /// dictionary to save the remote functions requests
    var remoteFunctionsRequests: [Int: ((Json) -> Void)?] = [:]
    
    public var useDidCommit: Bool = true
    
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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(openRequestNavigationsInNewTab: Bool = false) {
        self.openRequestNavigationsInNewTab = openRequestNavigationsInNewTab
        super.init()
    }
    
    /// Listen when url content is loaded   
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !useDidCommit {
            delegate?.onWebViewLoaded()
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if useDidCommit {
            delegate?.onWebViewLoaded()
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
    
    /// Listen window.open
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    )
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
    
    func buildResultFunction(requestId: Int, type: String) -> String {
        let handlerName = WebViewUserContentControllerNames.remoteJs
        return """
        function sendResult(data){
            window.webkit.messageHandlers.\(handlerName).postMessage(JSON.stringify({type:"\(type)", data: data , requestId: \(requestId) }));
        }
        """
    }
    
    
    /// Handle the result of calling javascript functions
    func handleRemoteFunctionResult(json: [String: Any]) {
        guard let requestId = json["requestId"] as? Int,
              let completition = remoteFunctionsRequests[requestId]
        else {
            return
        }

        let data = json["data"]
        if let data = data {
            completition!(data as! Json)
        }
        remoteFunctionsRequests.removeValue(forKey: requestId)
    }
    
    func executeRemoteJsFunction( jsBuilder:@escaping(_ requestId: Int) -> String, completion: @escaping (Json) -> Void) {
        // creates a unique id that will be used as a key of the remoteFunctionsRequests dictionary
        remoteFunctionsRequestId += 1
        remoteFunctionsRequests[remoteFunctionsRequestId] = completion
        
        let js = jsBuilder(remoteFunctionsRequestId)
        webView?.evaluateJavaScript(js){ result, error in
            if let error = error {
                DeunaLogs.error("Error evaluateJavaScript: \(error.localizedDescription)")
            }
        }
    }
    
    
    /// Handle post messages
    func allowPostMessageHandler(
        didReceive message: WKScriptMessage
    ) -> Bool {
        guard let messageBody = message.body as? String else {
            return false
        }

        switch message.name {
        case WebViewUserContentControllerNames.consoleLog:
            DeunaLogs.info("console.log: \(messageBody)")
            return false
            
        case WebViewUserContentControllerNames.remoteJs:
            guard let messageData = getMessageData(message: message) else {
                return false
            }
            handleRemoteFunctionResult(json: messageData.json)
           return false
            
        default:
            return true
        }
    }
    
    
    /// Class to store the post message data
    public class Message {
        let data: Foundation.Data
        let json: [String: Any]
        
        init(data: Foundation.Data, json: [String: Any]) {
            self.data = data
            self.json = json
        }
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
    
    
    func dispose(){
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.removeFromSuperview()
        webView?.stopLoading()
        webView = nil
    }
}
