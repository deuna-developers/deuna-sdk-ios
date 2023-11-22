import Foundation
import WebKit
import UIKit
import DEUNAClient
import SystemConfiguration


// MARK: - DeunaSDK Main Class
public class DeunaSDK: NSObject, WKNavigationDelegate {
    
    @objc public enum ElementType: Int {
        case vault

        var rawValue: String {
            switch self {
            case .vault:
                return "vault"
            }
        }
    }
    
    // MARK: - Public Nested Classes
    public class Callbacks: NSObject {
        public var onSuccess: ((Any) -> Void)? = nil
        public var onError: ((DeUnaErrorMessage) -> Void)? = nil
        public var onClose: ((WKWebView) -> Void)? = nil
        public var eventListener: ((CheckoutEventResponse) -> Void)? = nil
    }
    
    // MARK: - Public Static Properties
    public static let shared = DeunaSDK()
    
    // MARK: - Internal Properties
    internal let closeButtonTag = 4242
    internal var loader: UIActivityIndicatorView?
    internal var processing: Bool = false
    internal var DeunaWebView: WKWebView?
    internal var DeunaView: UIView?
    internal var shouldPresentInModal: Bool = false
    internal var callbacks: Callbacks = Callbacks()
    internal var showCloseButton: Bool = true
    internal var threeDsAuth: Bool = false
    internal var closeOnEvents: [CheckoutEventType] = []
    internal var environment: Environment!
    internal var subWebView: DeunaWebViewManager?
    internal var closeButtonConfig: CloseButtonConfig?
    internal var closeOnSuccess: Bool = true
    
    // MARK: - Private Properties
    internal var apiKey: String!
    internal var orderToken: String?
    internal var userToken: String?
    internal var elementType: ElementType!
    internal var elementURL: String = ""
    internal var actionMilliseconds: Int = 5000
    internal var isConfigured: Bool = false
    internal var keepLoaderVisible: Bool = false  // Property to determine if the loader should remain visible
    internal var webViewController = UIViewController()
    
    private var scriptSource = """
    window.open = function(open) {
        return function(url, name, features) {
            location.href = url; // or window.location.replace(url)
        };
    }(window.open);
    """
    
    
    // MARK: - Logging
    internal var isLoggingEnabled = false
    
    // MARK: - Initializers
    private override init() {
        super.init()
        let webViewController = UIViewController()
    }
    
    // MARK: - Public Configuration Methods
    
    // MARK: - Enable Logging
    public func enableLogging() {
        isLoggingEnabled = true
    }
    
    // MARK: - Disable Logging
    public func disableLogging() {
        isLoggingEnabled = false
    }
    
    // MARK: - Public Class Methods
    public class func config(
        apiKey: String,
        orderToken: String? = nil,
        userToken: String? = nil,
        environment: Environment,
        closeButtonConfig: CloseButtonConfig? = nil,
        presentInModal: Bool? = nil,
        showCloseButton: Bool? = nil,
        keepLoaderVisible: Bool? = false,
        closeOnEvents: [CheckoutEventType] = [],
        closeOnSuccess: Bool = true
    ) {
        // Default values
        let defaultPresentInModal = false
        let defaultShowCloseButton = true
        
        // Determine the actual values based on the provided parameters
        let actualPresentInModal = presentInModal ?? defaultPresentInModal
        let actualShowCloseButton = showCloseButton ?? (actualPresentInModal ? false : defaultShowCloseButton)
        
        assert(!(actualPresentInModal && actualShowCloseButton), "When presenting in a modal, the close button must be shown.")
        
        shared.apiKey = apiKey
        shared.orderToken = orderToken
        shared.userToken = userToken
        shared.environment = environment
        shared.closeButtonConfig = closeButtonConfig
        shared.shouldPresentInModal = actualPresentInModal
        shared.showCloseButton = actualShowCloseButton
        shared.closeOnSuccess = closeOnSuccess
        shared.closeOnEvents = closeOnEvents
        shared.keepLoaderVisible=keepLoaderVisible ?? false
        shared.enableLogging()
        // Set the element URL based on the environment
        if shared.environment == .development {
            shared.enableLogging()
            shared.elementURL = "https://pay.stg.deuna.com/elements"
        } else {
            shared.elementURL = "https://pay.deuna.com/elements"
        }
        //Mark the shared instance as configured
        shared.isConfigured = true
    }
    
    // MARK: - Allow overriding the order token so we can open different orders
    public func setOrderToken(newOrderToken: String) {
        assert(isConfigured, "You must call `config` before overriding the order token.")
        self.orderToken = newOrderToken
    }
    
    
    // MARK: - Public Checkout Methods
    
    // MARK: - initCheckout Instance Methods
    @objc public func initCheckout(callbacks: Callbacks, viewToEmbedWebView: UIView? = nil) {
        //Set threeDsAuth to false on every attempt
        self.threeDsAuth=false
        
        assert(isConfigured, "You must call `config` before calling `initCheckout`.")
        
        self.callbacks = callbacks
        
        guard isNetworkAvailable else {
            let error = DeUnaErrorMessage(message: "No internet connection available.", type: .noInternetConnection)
            callbacks.onError?(error)
            return
        }
        
        showLoader()
        
        // Set the basePath based on the environment
        if DeunaSDK.shared.environment == .production {
            DEUNAClientAPI.basePath = "https://apigw.getduna.com:443"
        } else if DeunaSDK.shared.environment == .staging {
            DEUNAClientAPI.basePath = "https://staging-apigw.getduna.com:443"
        } else if DeunaSDK.shared.environment == .sandbox {
            DEUNAClientAPI.basePath =  "https://apigw.sbx.getduna.com:443"
        } else {
            DEUNAClientAPI.basePath = "https://api.dev.deuna.io:443"
        }
        // Fetch order details and set up the WebView
        OrderAPI.getOrder(orderToken: orderToken!, xApiKey: DeunaSDK.shared.apiKey) { (orderResponse, error) in
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
            self.DeunaWebView?.backgroundColor = .clear
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
            
            self.presentWebView(viewToEmbedWebView: viewToEmbedWebView)
            
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
    
    
    @objc public func initElements(element: DeunaSDK.ElementType, callbacks: Callbacks, viewToEmbedWebView: UIView? = nil) {
        //Set threeDsAuth to false on every attempt
        self.threeDsAuth=false
        
        assert(isConfigured, "You must call `config` before calling `initElements`.")
        
        self.callbacks = callbacks
        
        guard isNetworkAvailable else {
            let error = DeUnaErrorMessage(message: "No internet connection available.", type: .noInternetConnection)
            callbacks.onError?(error)
            return
        }
        
        showLoader()
        
        // Set the basePath based on the environment
        let environmentUrls = [
            Environment.production: "https://elements.deuna.io/\(element.rawValue)",
            Environment.staging: "https://elements.stg.deuna.io/\(element.rawValue)",
            Environment.development: "https://elements.dev.deuna.io/\(element.rawValue)"
        ]

        if let baseUrl = environmentUrls[DeunaSDK.shared.environment],
           let userToken = userToken,
           let apiKey = apiKey {
            elementURL = "\(baseUrl)?userToken=\(userToken)&publicApiKey=\(apiKey)"
        }
        
        
        // Fetch order details and set up the WebView
        let userScript = WKUserScript(source: self.scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "deuna")
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.userContentController.addUserScript(userScript)
        
        
        
        self.DeunaWebView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        self.DeunaWebView?.navigationDelegate = self
        self.DeunaWebView?.backgroundColor = .clear
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
        
        self.presentWebView(viewToEmbedWebView: viewToEmbedWebView)
        
        // Load the payment link if available
        
        self.log("Loading element link: \(elementURL)")
        let urlRequest = URLRequest(url: URL(string: elementURL)!)
        self.DeunaWebView?.load(urlRequest)
        
    }
    
    
    @objc public func closeCheckout() {
        log("closing checkout")
        // Check if the modal or WebView can be dismissed
        guard canDismiss() else {
            self.log("Cannot dismiss the modal or WebView because processing is true.")
            return
        }
        // If the SDK is presented as a modal, dismiss the modal
        self.hideLoader()
        if keepLoaderVisible{
            showLoader()
        }
        if self.DeunaWebView != nil {
            callbacks.onClose?(self.DeunaWebView!)
        }
        self.webViewController.dismiss(animated: true, completion: nil)
        self.DeunaWebView?.removeFromSuperview()
    }
    
    internal func createCloseButton() -> UIButton {
        let defaultConfig = CloseButtonConfig()
        let config = closeButtonConfig ?? defaultConfig
        
        let button = UIButton(frame: config.frame)
        button.setTitle(config.title, for: .normal)
        button.setTitleColor(config.titleColor, for: .normal)
        button.backgroundColor = config.backgroundColor

        // Use the system close icon for iOS 13.0 and later
        if #available(iOS 13.0, *) {
            let iconImage = UIImage(systemName: "xmark")
            button.setImage(iconImage, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            // remove the title
            button.setTitle("", for: .normal)
        }

        button.addTarget(self, action: #selector(closeCheckout), for: .touchUpInside)
        return button
    }
    
    internal func ProcessingStarted(){
        log("ProcessingStarted")
        self.processing = true
        hideCloseButtonInView()
    }
    
    internal func ProcessingEnded(_ reason:String){
        log("ProcessingEnded \(reason)")
        self.processing = false
        showCloseButtonInView()
    }
    
    
    // MARK: - Private Helper Methods
    
    private func HandleError(error : Error){
        self.log("found Error=\(error)",error:error)
        self.hideLoader()
        self.closeCheckout()
        callbacks.onError?(DeUnaErrorMessage(message: error.localizedDescription, type: .checkoutInitializationFailed))
        return
    }
    
    
    
    @objc func closeSubWebView() {
        if self.subWebView != nil{
            subWebView?.closeSubWebView()
            subWebView = nil
        }
    }
    
    // MARK: - Network Reachability
    internal var isNetworkAvailable: Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}

