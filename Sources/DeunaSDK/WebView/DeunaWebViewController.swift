//
//  BaseWebviewController.swift
//
//
//  Created on 6/3/24.
//

import Foundation
import UIKit
@preconcurrency import WebKit

// Keywords to recognize a url that should be opened externally (safari)
let keysForExternalUrls = ["vapormicuenta"]

public typealias OnWidgetClosed = () -> Void

/// A base view controller for handling web views.
class DeunaWebViewController: BaseWebViewController, DeunaWebViewDelegate, WKScriptMessageHandler {
    var activityIndicator: UIActivityIndicatorView?
    var configuration: WKWebViewConfiguration!
    
    let sdkConfiguration: DeunaSDKConfiguration
    var webViewLoaded = false
    
    public var closeAction: CloseAction = .userAction
   
    public var onWidgetClosed: OnWidgetClosed? = nil
    
    // When this var is false the close feature is disabled
    public var dismissible = true
    
    // Must be true when the widget is loaded inside a SwiftUI View
    public var isEmbeddedWidget: Bool!
    
    let externalUrlHandler = ExternalUrlHandler()
    
    let fraudCredentials: Json?
    var fraudId = ""
    /// Optional custom User-Agent explicitly provided by the SDK consumer.
    /// If present and non-empty, this value is applied to `WKWebView.customUserAgent`
    /// before loading the widget URL, and it has priority when building
    /// the `user_agent` field returned in onSuccess payloads.
    let customUserAgent: String?
    
    // Define the JS xprops callbacks to be compatible with the payment link
    // that uses zoid to notify the messages
    var scriptSource: String!
    
    init(
        sdkConfiguration: DeunaSDKConfiguration,
        hidePayButton: Bool? = false,
        isEmbeddedWidget: Bool? = false,
        fraudCredentials: Json? = nil,
        customUserAgent: String? = nil
    ) {
        self.sdkConfiguration = sdkConfiguration
        self.isEmbeddedWidget = isEmbeddedWidget
        self.customUserAgent = customUserAgent
        scriptSource = """
        
        console.log = function(message) {
            window.webkit.messageHandlers.\(WebViewUserContentControllerNames.consoleLog).postMessage(message);
        };
        
        window.xprops = {
            hidePayButton: \(hidePayButton!),
            onEventDispatch: function (event) {
                window.webkit.messageHandlers.\(WebViewUserContentControllerNames.xprops).postMessage(JSON.stringify(event));
            },
            onCustomCssSubscribe: function (fn)  {
                window.setCustomCss = fn;
            },
            onCustomStyleSubscribe: function (fn)  {
                window.setCustomStyle = fn;
            },
            onRefetchOrderSubscribe: function (fn) {
                window.deunaRefetchOrder = fn;
            },
            onGetStateSubscribe: function (state){
               window.deunaWidgetState = state;
            },
            isValid: function(fn){
                window.isValid = fn;
            },
            onSubmit: function(fn){
                window.submit = fn;
            },
            getFraudId: function(){
                if(typeof window.getFraudId === 'function'){
                    return window.getFraudId();
                }
                return "";
            }
        };
        """
        
        self.fraudCredentials = fraudCredentials
        
        super.init(openRequestNavigationsInNewTab: true)
       
        DeunaTasks.run {
            self.configuration = WKWebViewConfiguration()
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        showLoader()
    }
    
    /// Loads the web view with the specified URL.
    ///
    /// - Parameter urlString: The URL string to load.
    func loadUrl(urlString: String) {
        guard let url = URL(string: urlString) else {
            onLoadError(code: -1, message: "Invalid URL string")
            return
        }
  
        DeunaTasks.run {
            if let fraudCredentials = self.fraudCredentials {
                if #available(iOS 14.0, *) {
                    DeunaSDK(
                        environment: self.sdkConfiguration.environment,
                        publicApiKey: self.sdkConfiguration.publicApiKey
                    ).generateFraudId(params: fraudCredentials) { (result) in
                        self.fraudId = result ?? ""
                        if self.webViewLoaded {
                            self.injectGetFraudIdFn()
                        }
                    }
                }
            }
            
            self.injectJs()
            self.controller.webView = WKWebView(frame: self.view.bounds, configuration: self.configuration)
            self.controller.deunaDelegate = self
            if let customUserAgent = self.customUserAgent?.trimmingCharacters(in: .whitespacesAndNewlines), !customUserAgent.isEmpty {
                self.controller.webView?.customUserAgent = customUserAgent
            }
            
            self.controller.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                   
            let request = URLRequest(url: url)
            self.controller.webView?.load(request)
        }
    }
    
    func injectGetFraudIdFn(){
        controller.webView?.evaluateJavaScript("window.getFraudId = function() { return '\(fraudId)';};")
    }

    /// Resolves the effective User-Agent to be reported for widget success payloads.
    ///
    /// - Parameter completion: Async callback with the resolved UA or `nil`.
    func resolveEffectiveUserAgent(completion: @escaping (String?) -> Void) {
         guard let webView = controller.webView else {
            completion(nil)
            return
        }
        
        if let userAgent = webView.customUserAgent?.trimmingCharacters(in: .whitespacesAndNewlines), !userAgent.isEmpty {
            completion(userAgent)
            return
        }

        webView.evaluateJavaScript("navigator.userAgent") { result, _ in
            let userAgent = (result as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let userAgent, !userAgent.isEmpty {
                completion(userAgent)
                return
            }
            completion(nil)
        }
    }

    /// Reusable helper to merge additional fields into an onSuccess payload.
    ///
    /// Existing payload keys are overwritten by keys present in `extras`.
    /// This keeps payload enrichment logic centralized and reusable across
    /// multiple metadata fields (for example `user_agent`, `fraud_id`, etc).
    ///
    /// - Parameters:
    ///   - payload: Base payload received from widget events.
    ///   - extras: Extra fields to be merged into the payload.
    /// - Returns: A new merged payload.
    func enrichSuccessPayload(_ payload: Json, extras: Json) -> Json {
        var enrichedPayload = payload
        for (key, value) in extras {
            enrichedPayload[key] = value
        }
        return enrichedPayload
    }

    /// Convenience helper used by widget controllers before firing `onSuccess`.
    ///
    /// It resolves the effective UA and returns a payload enriched with
    /// `user_agent` and `fraud_id`.
    /// This centralizes enrichment logic in the base controller to keep
    /// widget-specific event handlers simple and consistent across
    /// Checkout/Payment/NextAction/Voucher/Elements.
    ///
    /// - Parameters:
    ///   - payload: Original success payload.
    ///   - completion: Callback receiving the enriched payload.
    func buildSuccessPayload(_ payload: Json, completion: @escaping (Json) -> Void) {
        resolveEffectiveUserAgent { [weak self] userAgent in
            guard let self = self else {
                completion(payload)
                return
            }
            var extras: Json = [:]
            if let userAgent = userAgent?.trimmingCharacters(in: .whitespacesAndNewlines), !userAgent.isEmpty {
                extras["user_agent"] = userAgent
            }else {
                extras["user_agent"] = NSNull()
            }
            let fraudId = self.fraudId.trimmingCharacters(in: .whitespacesAndNewlines)
            if !fraudId.isEmpty {
                extras["fraud_id"] = fraudId
            } else {
                extras["fraud_id"] = NSNull()
            }
            let enrichedPayload = self.enrichSuccessPayload(payload, extras: extras)
            completion(enrichedPayload)
        }
    }
    
    /// Dismisses the web view controller.
    func closeWebView(_ closeAction: CloseAction) {
        self.closeAction = closeAction
        externalUrlHandler.closeExternalUrlWebView()
        dismiss(animated: true)
    }
    
    /// function that can be override to listen when an error  is throw during the url loading
    func onLoadError(code: Int, message: String) {}

    /// Configures whether the modal close action is enabled or disabled
    /// - Parameter enabled: A boolean value indicating if the modal close action should be enabled (`true`) or disabled (`false`)
    public func setCloseEnabled(_ enabled: Bool) {
        // Sets whether the modal is dismissible
        dismissible = enabled
        
        // On iOS 13.0 or later, configures whether the modal is locked on the screen
        if #available(iOS 13.0, *) {
            isModalInPresentation = !enabled
        }
    }
    
    func onWebViewLoaded() {
        view.addSubview(controller.webView!)
        webViewLoaded = true
        
        if !fraudId.isEmpty {
            injectGetFraudIdFn()
        }
        
        if !isEmbeddedWidget {
            addDismissLineBar()
        }
       
        // wait until url is loaded to set the webview height
        controller.webView!.frame.size.height = view.frame.height
        controller.webView!.frame.size.width = view.frame.width
        view.translatesAutoresizingMaskIntoConstraints = false
        controller.webView!.scrollView.isScrollEnabled = true
        hideLoader() // Called when the URL has finished loading completely
    }
    
    func onWebviewError(_ errorCode: Int) {
        onLoadError(
            code: errorCode,
            message: LoadUrlErrorMessages.getMessage(code: errorCode)
        )
    }
    
    func onOpenInNewTab(_ url: URL) {
        
        if externalUrlHandler.isVisible {
            return
        }
        
        DeunaLogs.info(url.absoluteString)
        let browser: ExternalUrlHandlerBrowser =
            shouldOpenInSafariViewController(url) ? .safariView : .webView

        externalUrlHandler.open(with: url, browser: browser, parent: self){
            self.dismissible = true
        }
    }
    
    private func shouldOpenInSafariViewController(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }

        for domain in domainsRequiringSafariViewController {
            if host.contains(domain) {
                return true
            }
        }
        return false
    }
    
    func onDownloadFile(_ url: URL) {}
    
    override func viewDidDisappear(_ animated: Bool) {
        if !externalUrlHandler.isVisible {
            dispose()
        }
    }

    
    func downloadVoucher(data: Json) {
        showLoader()
        if let voucherUrl = (data[APMsConstants.metadata] as? Json)?[APMsConstants.voucherPdfDownloadUrl] as? String {
            downloadFile(urlString: voucherUrl) {
                self.hideLoader()
            }
        } else {
            takeScreenshot {
                self.hideLoader()
            }
        }
    }
    
    func dispose(_ completion: VoidCallback? = nil) {
        externalUrlHandler.waitUntilSafariViewIsClosed {
            self.externalUrlHandler.closeExternalUrlWebView()
            // Clean up the WKWebView when the view controller is destroyed
            self.controller.dispose()
            self.onWidgetClosed?()
            completion?()
        }
    }
}
