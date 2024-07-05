import DEUNAClient
import Foundation
import WebKit

/// Extension of DeunaSDK to handle checkout-related functionalities.
public extension DeunaSDK {
    /// Initializes the checkout process.
    ///
    /// - Parameters:
    ///   - orderToken: The token representing the order.
    ///   - callbacks: The callbacks to handle checkout events.
    ///   - closeEvents: A Set of CheckoutEvent values specifying when to close the checkout automatically.
    func initCheckout(
        orderToken: String,
        callbacks: CheckoutCallbacks,
        closeEvents: Set<CheckoutEvent> = [],
        userToken: String? = nil
    ) {
        guard !orderToken.isEmpty else {
            DeunaLogs.error("orderToken must not be empty")
            handleCheckoutError(.invalidOrderToken, callbacks: callbacks)
            return
        }
        
        // Initialize the checkout web view controller with the provided callbacks and close events
        checkoutWebViewController = CheckoutViewController(callbacks: callbacks, closeEvents: closeEvents)

        // Show the checkout web view controller
        if !showWebView(webViewController: checkoutWebViewController!) {
            return
        }

        // Check for internet connectivity
        guard NetworkUtils.hasInternet else {
            handleCheckoutError(.noInternetConnection, callbacks: callbacks)
            return
        }
        
        // Fetch order details using a dedicated error handling function
        fetchOrderDetails(orderToken: orderToken) { orderResponse, error in
            if error != nil {
                self.handleCheckoutError(.checkoutInitializationFailed, callbacks: callbacks)
                return
            }

            // Load the payment link if available
            if let order = orderResponse?.order, let paymentLink = order.paymentLink {
                // START Building the checkout url using the userToken
                guard var urlComponents = URLComponents(string: paymentLink) else {
                    self.handleCheckoutError(.checkoutInitializationFailed, callbacks: callbacks)
                    return
                }
                
                var queryParameters = [URLQueryItem]()
                queryParameters.append(URLQueryItem(name: QueryParameters.mode, value: QueryParameters.widget))
                if userToken != nil, !userToken!.isEmpty {
                    queryParameters.append(URLQueryItem(name: QueryParameters.userToken, value: userToken))
                }
                       
                urlComponents.queryItems = queryParameters
                guard let link = urlComponents.url?.absoluteString else {
                    self.handleCheckoutError(.checkoutInitializationFailed, callbacks: callbacks)
                    return
                }
                
                DeunaLogs.debug("Loading payment link: \(link)")
                self.checkoutWebViewController?.loadUrl(urlString: link)
            } else {
                self.handleCheckoutError(.checkoutInitializationFailed, callbacks: callbacks)
            }
        }
    }
    
    // Fetch order details using the provided order token and private API key
    private func fetchOrderDetails(orderToken: String, completion: @escaping (GetOrder200Response?, Error?) -> Void) {
        DEUNAClientAPI.basePath = environment.baseUrls.clientApiBaseUrl
        OrderAPI.getOrder(orderToken: orderToken, xApiKey: publicApiKey) { orderResponse, error in
            completion(orderResponse, error)
        }
    }
    
    /// Closes the checkout process if it is currently active.
    func closeCheckout() {
        guard let checkoutVC = checkoutWebViewController, checkoutVC.isViewLoaded, checkoutVC.view.window != nil else {
            return
        }
        checkoutVC.closeWebView()
    }
    
    /// Method to handle SDK errors.
    private func handleCheckoutError(
        _ errorType: CheckoutErrorType,
        callbacks: CheckoutCallbacks
    ) {
        let error = CheckoutError(type: errorType)
        callbacks.onError?(error)
    }
}
