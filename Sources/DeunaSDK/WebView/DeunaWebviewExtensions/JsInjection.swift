//
//  JsInjection.swift
//  DeunaSDK
//
//  Created by DEUNA on 21/10/24.
//

import WebKit



extension DeunaWebViewController {
    
    /// Inject and load the necessary JS code to listen the web view events
    func injectJs() {
        let userScript = WKUserScript(
            source: scriptSource,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.deuna)
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.xprops)
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.consoleLog)
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.remoteJs)
    
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.userContentController.addUserScript(userScript)
    }
    
    /// send a JSON through javascript postMessage
    public func postMessage(json: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                controller.webView?.evaluateJavaScript("javascript:postMessage(JSON.stringify(\(jsonString)),'*')")
            }
        } catch {
            DeunaLogs.error(error.localizedDescription)
        }
    }

}
