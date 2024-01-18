//
//  DeunaSDK+Initializers.swift
//
//

import Foundation
import UIKit
import DEUNAClient
import WebKit
extension DeunaSDK{
    // MARK: - initCheckout Instance Methods
    @objc public func initCheckout(callbacks: Callbacks, viewToEmbedWebView: UIView? = nil, orderToken: String?) {
        assert(isConfigured, "You must call `config` before calling `initCheckout`.")

        //Set threeDsAuth to false on every attempt
        let token = orderToken  ?? DeunaSDK.shared.orderToken
        assert(token != nil, "You must provide an order token or configure an order token using DeunaSDK.shared.config")
        print("getting token")
        print(token!)
        self.threeDsAuth=false

        self.callbacks = callbacks
        
        guard isNetworkAvailable else {
            let error = DeUnaErrorMessage(message: "No internet connection available.", type: .noInternetConnection)
            callbacks.onError?(error)
            return
        }
        
        showLoader()
        
        switch DeunaSDK.shared.environment {
        case .production:
            DEUNAClientAPI.basePath = "https://apigw.getduna.com:443"
        case .staging:
            DEUNAClientAPI.basePath = "https://staging-apigw.getduna.com:443"
        case .sandbox:
            DEUNAClientAPI.basePath = "https://apigw.sbx.getduna.com:443"
        default:
            DEUNAClientAPI.basePath = "https://api.dev.deuna.io:443"
        }

        // Fetch order details and set up the WebView
        OrderAPI.getOrder(orderToken: token!, xApiKey: DeunaSDK.shared.apiKey) { (orderResponse, error) in
            if error != nil{
                return self.HandleError(error: error!)
            }
            
            
            let userScript = WKUserScript(source: self.scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            
            let configuration = WKWebViewConfiguration()
            configuration.userContentController.add(self, name: "deuna")
            configuration.preferences.javaScriptEnabled = true
            configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
            configuration.userContentController.addUserScript(userScript)
            
            
            
            self.DeunaWebView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
            self.DeunaWebView?.navigationDelegate = self
            self.DeunaWebView?.backgroundColor = UIColor.white
            self.DeunaWebView?.isOpaque = false
            if #available(iOS 10.0, *) {
                self.DeunaWebView?.scrollView.refreshControl = nil
            }
            // Enable inspection for development environment
            if self.DeunaWebView != nil && DeunaSDK.shared.environment == .development {
                if self.DeunaWebView!.responds(to: Selector(("setInspectable:"))) {
                    self.DeunaWebView!.perform(Selector(("setInspectable:")), with: true)
                }
            }
            
            self.presentWebView(viewToEmbedWebView: viewToEmbedWebView,webView: self.DeunaWebView!)
            
            // Load the payment link if available
            if let order = orderResponse?.order {
                if let paymentLink = order.paymentLink {
                    self.log("Loading payment link: \(paymentLink)")
                    let urlRequest = URLRequest(url: URL(string: paymentLink)!)
                    self.DeunaWebView?.load(urlRequest)
                } else {
                    self.log("Payment link is nil.")
                    self.closeCheckout()
                    callbacks.onError?(DeUnaErrorMessage(message: "Initialization failed", type: .checkoutInitializationFailed))
                    return
                }
            } else if let error = error {
                let error = DeUnaErrorMessage(message: "Order not found.", type: .orderError)
                callbacks.onError?(error)
                self.closeCheckout()
                return
            }
        }
    }
    
    
    @objc public func initElements(element: DeunaSDK.ElementType, callbacks: ElementsCallbacks, viewToEmbedWebView: UIView? = nil, userToken: String?) {
        
        assert(isConfigured, "You must call `config` before calling `initElements`.")
        
        //Set threeDsAuth to false on every attempt
        let token =  userToken ?? DeunaSDK.shared.userToken
        assert(token != nil, "You must provide a user token or configure a user token using DeunaSDK.shared.config")

        self.threeDsAuth=false
        
        self.elementsCallbacks = callbacks
        
        guard isNetworkAvailable else {
            let error = DeUnaErrorMessage(message: "No internet connection available.", type: .noInternetConnection)
            elementsCallbacks.onError?(error)
            return
        }
        
        showLoader()
        
        // Set the basePath based on the environment
        let environmentUrls = [
            Environment.production: "https://elements.deuna.io/vault",
            Environment.staging: "https://elements.stg.deuna.io/vault",
            Environment.development: "https://elements.dev.deuna.io/vault",
            Environment.sandbox: "https://elements.sandbox.deuna.io/vault"
        ]
        if let baseUrl = environmentUrls[DeunaSDK.shared.environment],
           let apiKey = apiKey {
            elementURL = "\(baseUrl)?userToken=\(token!)&publicApiKey=\(apiKey)&mode=widget"
        }
                
        
        // Fetch order details and set up the WebView
        let userScript = WKUserScript(source: self.scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "deuna")
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.userContentController.addUserScript(userScript)
        
        
        
        self.DeunaElementsWebView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        self.DeunaElementsWebView?.navigationDelegate = self
        self.DeunaElementsWebView?.backgroundColor = UIColor.white
        self.DeunaElementsWebView?.isOpaque = false
        if #available(iOS 10.0, *) {
            self.DeunaElementsWebView?.scrollView.refreshControl = nil
        }
        // Enable inspection for development environment
        if self.DeunaElementsWebView != nil && DeunaSDK.shared.environment == .development {
            if self.DeunaElementsWebView!.responds(to: Selector(("setInspectable:"))) {
                self.DeunaElementsWebView!.perform(Selector(("setInspectable:")), with: true)
            }
        }
        
        self.presentWebView(viewToEmbedWebView: viewToEmbedWebView,webView: self.DeunaElementsWebView!)
        
        // Load the payment link if available
        
        self.log("Loading element link: \(elementURL)")
        let urlRequest = URLRequest(url: URL(string: elementURL)!)
        self.DeunaElementsWebView?.load(urlRequest)
    }
}
