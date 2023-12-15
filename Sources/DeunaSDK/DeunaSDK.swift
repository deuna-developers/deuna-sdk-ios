import Foundation
import WebKit
import UIKit
import DEUNAClient
import SystemConfiguration


// MARK: - DeunaSDK Main Class
public class DeunaSDK: NSObject, WKNavigationDelegate {
    
    @objc public enum ElementType: Int {
        case vault
    }
    
    // MARK: - Public Nested Classes
    public class Callbacks: NSObject {
        public var onSuccess: ((CheckoutEventResponse) -> Void)? = nil
        public var onError: ((DeUnaErrorMessage) -> Void)? = nil
        public var onClose: (() -> Void)? = nil
        public var eventListener: ((CheckoutEventType,CheckoutEventResponse) -> Void)? = nil
    }
    
    // MARK: - Public Nested Classes
    public class ElementsCallbacks: NSObject {
        public var onSuccess: ((ElementEventResponse) -> Void)? = nil
        public var onError: ((DeUnaErrorMessage) -> Void)? = nil
        public var onClose: (() -> Void)? = nil
        public var eventListener: ((CheckoutEventType,ElementEventResponse) -> Void)? = nil
    }
    
    // MARK: - Public Static Properties
    public static let shared = DeunaSDK()
    
    // MARK: - Internal Properties
    internal var loader: UIActivityIndicatorView?
    internal var processing: Bool = false
    internal var DeunaWebView: WKWebView?
    internal var DeunaElementsWebView: WKWebView?
    internal var DeunaView: UIView?
    internal var shouldPresentInModal: Bool = false
    internal var callbacks: Callbacks = Callbacks()
    internal var elementsCallbacks: ElementsCallbacks = ElementsCallbacks()
    internal var threeDsAuth: Bool = false
    internal var closeOnEvents: [CheckoutEventType] = []
    internal var environment: Environment!
    internal var subWebView: DeunaWebViewManager?
    internal var closeOnSuccess: Bool = true
    
    // MARK: - Private Properties
    internal var apiKey: String!
    internal var orderToken: String!
    internal var userToken: String!
    internal var elementType: ElementType!
    internal var elementURL: String = ""
    internal var actionMilliseconds: Int = 5000
    internal var isConfigured: Bool = false
    internal var keepLoaderVisible: Bool = false  // Property to determine if the loader should remain visible
    internal var webViewController = UIViewController()
    internal var elementsWebViewController = UIViewController()
    
    internal var scriptSource = """
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
        let elementsWebViewController = UIViewController()
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
    @available(*, deprecated, message: "You should pass orderToken to .initCheckout and userToken to .initElemnts , this parameters will be removed in future versions")
    public class func config(
        apiKey: String,
        orderToken: String?,
        userToken: String?,
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
        
        // Determine the actual values based on the provided parameters
        let actualPresentInModal = presentInModal ?? defaultPresentInModal
        
        assert(!(actualPresentInModal), "When presenting in a modal, the close button must be shown.")
        
        shared.apiKey = apiKey
        shared.environment = environment
        shared.shouldPresentInModal = actualPresentInModal
        shared.closeOnSuccess = closeOnSuccess
        shared.closeOnEvents = closeOnEvents
        shared.keepLoaderVisible=keepLoaderVisible ?? false
        shared.enableLogging()
        // Set the element URL based on the environment
        if shared.environment == .development {
            shared.enableLogging()
        }
        //Mark the shared instance as configured
        shared.isConfigured = true
    }
    
    public class func config(
        apiKey: String,
        environment: Environment,
        presentInModal: Bool? = nil,
        keepLoaderVisible: Bool? = false,
        closeOnEvents: [CheckoutEventType] = [],
        closeOnSuccess: Bool = true
    ) {
        // Default values
        let defaultPresentInModal = false
        let defaultShowCloseButton = true
        
        // Determine the actual values based on the provided parameters
        let actualPresentInModal = presentInModal ?? defaultPresentInModal
        
        assert(!(actualPresentInModal), "When presenting in a modal, the close button must be shown.")
        
        shared.apiKey = apiKey
        shared.environment = environment
        shared.shouldPresentInModal = actualPresentInModal
        shared.closeOnSuccess = closeOnSuccess
        shared.closeOnEvents = closeOnEvents
        shared.keepLoaderVisible=keepLoaderVisible ?? false
        shared.enableLogging()
        // Set the element URL based on the environment
        if shared.environment == .development {
            shared.enableLogging()
        }
        //Mark the shared instance as configured
        shared.isConfigured = true
    }
    
    @objc public func closeCheckout() {
        log("closing checkout")
        self.closeView()
    }
    
    @objc func closeView() {
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
            callbacks.onClose?()
        }
        self.webViewController.dismiss(animated: true, completion: nil)
        self.elementsWebViewController.dismiss(animated: true, completion: nil)
        self.DeunaWebView?.removeFromSuperview()
        self.DeunaElementsWebView?.removeFromSuperview()
        self.DeunaView?.removeFromSuperview()

    }
    
    @objc public func closeElements() {
        log("closing elements")
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
        if self.DeunaElementsWebView != nil {
            elementsCallbacks.onClose?()
        }
        self.elementsWebViewController.dismiss(animated: true, completion: nil)
        self.DeunaElementsWebView?.removeFromSuperview()
        self.DeunaView?.removeFromSuperview()
    }
        
    internal func ProcessingStarted(){
        log("ProcessingStarted")
        self.processing = true
    }
    
    internal func ProcessingEnded(_ reason:String){
        log("ProcessingEnded \(reason)")
        self.processing = false
    }
    
    
    // MARK: - Private Helper Methods
    
    internal func HandleError(error : Error){
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

