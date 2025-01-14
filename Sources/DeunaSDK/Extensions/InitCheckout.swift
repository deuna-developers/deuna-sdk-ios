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
    ///   - userToken: (Optional) A user authentication token that allows skipping the OTP flow and shows the user's saved cards.
    ///   - styleFile: (Optional) An UUID provided by DEUNA. This applies if you want to set up a custom CSS file.
    func initCheckout(
        orderToken: String,
        callbacks: CheckoutCallbacks,
        closeEvents: Set<CheckoutEvent> = [],
        userToken: String? = nil,
        styleFile: String? = nil
    ) {
        guard !orderToken.isEmpty else {
            DeunaLogs.error(PaymentsErrorMessages.orderTokenMustNotBeEmpty)
            callbacks.onError?(PaymentWidgetErrors.invalidOrderToken)
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
            callbacks.onError?(PaymentWidgetErrors.noInternetConnection)
            return
        }
        
        // Fetch order details using a dedicated error handling function
        fetchOrderDetails(orderToken: orderToken) { orderResponse, error in
            if error != nil {
                callbacks.onError?(PaymentWidgetErrors.orderCouldNotBeRetrieved)
                return
            }

            // Load the payment link if available
            if let order = orderResponse?.order, let paymentLink = order.paymentLink , !paymentLink.isEmpty {
                // START Building the checkout url using the userToken
                var queryParameters: [(String, String)] = []
                queryParameters.append((QueryParameters.mode, QueryParameters.widget))
                
                if userToken != nil, !userToken!.isEmpty {
                    queryParameters.append((QueryParameters.userToken, userToken!))
                }
                
                if styleFile != nil, !styleFile!.isEmpty {
                    queryParameters.append((QueryParameters.styleFile, styleFile!))
                }
                       
                guard let link = buildUrl(baseUrl: paymentLink, queryParameters: queryParameters) else {
                    callbacks.onError?(PaymentWidgetErrors.linkCouldNotBeGenerated)
                    return
                }
                
                DeunaLogs.debug("Loading payment link: \(link)")
                self.checkoutWebViewController?.loadUrl(urlString: link)
            } else {
                callbacks.onError?(PaymentWidgetErrors.linkCouldNotBeGenerated)
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
    @available(*, deprecated, message: "Use close function instead.", renamed: "close")
    func closeCheckout() {
        close()
    }
}
