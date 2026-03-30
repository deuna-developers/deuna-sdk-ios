//
//  GenerateFraudId.swift
//  DeunaSDK
//
//  Created by deuna on 9/4/25.
//

import WebKit

@available(iOS 14.0, *)
public extension DeunaSDK {
    func generateFraudId(params: Json? = nil, completion: @escaping (String?) -> Void) {
        
        _ =  FraudIdGenerator(
            publicApiKey: self.configuration.publicApiKey,
            environment: self.configuration.environment,
            params: params,
            callback: completion
        )
    }
}

@available(iOS 14.0, *)
class FraudIdGenerator: NSObject, WKScriptMessageHandler, DeunaWebViewDelegate {
    let controller: WebViewController
    let publicApiKey: String
    let environment: Environment
    let params: Json?
    let callback: (String?) -> Void
    
    var configuration: WKWebViewConfiguration!
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(
        publicApiKey: String,
        environment: Environment,
        params: Json? = nil,
        callback: @escaping (String?) -> Void
    ) {
        self.publicApiKey = publicApiKey
        self.environment = environment
        self.callback = callback
        self.params = params
        self.controller = WebViewController()
        self.controller.useDidCommit = false
        
        super.init()
        
        DeunaTasks.run {
            self.configuration = WKWebViewConfiguration()
            self.injectJs()
            self.controller.webView = WKWebView(frame: .zero, configuration: self.configuration)
            self.controller.deunaDelegate = self
            
            guard let url = URL(string: "https://cdn.stg.deuna.io/mobile-sdks/get_fraud_id.html") else {
                callback(nil)
                self.controller.dispose()
                return
            }
            self.controller.webView?.load(URLRequest(url: url))
        }
    }
    
    func injectJs() {
        let scriptSource = """
        console.log = function(message) {
            window.webkit.messageHandlers.\(WebViewUserContentControllerNames.consoleLog).postMessage(message);
        };
        console.error = function(message) {
            window.webkit.messageHandlers.\(WebViewUserContentControllerNames.consoleLog).postMessage(message);
        };
        """
        
        let userScript = WKUserScript(
            source: scriptSource,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.consoleLog)
        configuration.userContentController.add(self, name: WebViewUserContentControllerNames.remoteJs)
    
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.preferences.javaScriptEnabled = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // Permitir acceso a recursos externos
        configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        configuration.userContentController.addUserScript(userScript)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        _ = controller.allowPostMessageHandler(didReceive: message)
    }
    
    func onWebViewLoaded() {
        generateFraudId()
    }
    
    func onWebviewError(_ errorCode: Int) {
        DeunaLogs.error("\(#function) - errorCode: \(errorCode)")
        callback(nil)
        controller.dispose()
    }
    
    func onOpenInNewTab(_ url: URL) {}
    
    func onDownloadFile(_ url: URL) {}
    
    private func generateFraudId() {
        controller.executeRemoteJsFunction(
            jsBuilder: { requestId in
                """
                (function() {
                    \(self.controller.buildResultFunction(requestId: requestId, type: "generateFraudId"))

                    if(typeof window.generateFraudId !== 'function'){
                        sendResult({ fraudId: null });
                        return;
                    }
                
                    window.generateFraudId(
                        {
                           publicApiKey: "\(self.publicApiKey)",
                           env: "\(self.environment.name)",
                           \(self.params != nil ? "params: \(self.params?.encode() ?? "{}")" : "")
                        }
                   )
                   .then((fraudId) => {
                      sendResult({ fraudId: fraudId })
                    })
                   .catch((error) => {
                      sendResult({ fraudId:null })
                    }
                   );
                })();
                """
            },
            completion: { data in
                let fraudId = data["fraudId"] as? String
                self.callback(fraudId)
                self.controller.dispose()
            }
        )
    }
}
