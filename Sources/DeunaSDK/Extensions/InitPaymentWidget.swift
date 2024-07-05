import Foundation

public extension DeunaSDK {
    /// Initializes the payment process using the DEUNA payment widget.
    ///
    /// - Parameters:
    ///   - orderToken: The token representing the order.
    ///   - callbacks: The callbacks to handle payment events.
    func initPaymentWidget(
        orderToken: String,
        callbacks: PaymentWidgetCallbacks,
        userToken: String? = nil
    ) {
        guard !orderToken.isEmpty else {
            DeunaLogs.error("orderToken must not be empty")
            callbacks.onError?(.initializationFailed)
            return
        }
        
        // Initialize the elements web view controller with the provided callbacks and close events
        paymentWidgetViewController = PaymentWidgetViewController(callbacks: callbacks)
        
        // Show the elements web view controller
        if !showWebView(webViewController: paymentWidgetViewController!) {
            return
        }
        
        // Check for internet connectivity
        guard NetworkUtils.hasInternet else {
            return
        }
        
        // Construct the base URL for the payment widget
        let baseUrl = "\(environment.baseUrls.paymentWidgetBaseUrl)/now/\(orderToken)"
        
        // START Building the checkout url using the userToken
        guard var urlComponents = URLComponents(string: baseUrl) else {
            callbacks.onError?(.initializationFailed)
            return
        }
        
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: QueryParameters.mode, value: QueryParameters.widget))
        
        if userToken != nil, !userToken!.isEmpty {
            queryParameters.append(URLQueryItem(name: QueryParameters.userToken, value: userToken))
        }
               
        urlComponents.queryItems = queryParameters
        guard let link = urlComponents.url?.absoluteString else {
            callbacks.onError?(.initializationFailed)
            return
        }
        
        // Set the presentation controller delegate and load the elements URL
        paymentWidgetViewController?.presentationController?.delegate = self
        DeunaLogs.debug("Loading payment widget link: \(link)")
        paymentWidgetViewController?.loadUrl(urlString: link)
    }
    
    /// Closes the payment widget if it is currently active.
    func closePaymentWidget() {
        guard let viewController = paymentWidgetViewController, viewController.isViewLoaded, viewController.view.window != nil else {
            return
        }
        viewController.closeWebView()
    }
    
    /// Set custom styles on the payment widget.
    /// This function must be only called inside the onCardBinDetected callback
    /// - Parameters:
    ///   - data: The JSON data to update the payment widget UI
    func setCustomCss(data: [String: Any]) {
        paymentWidgetViewController?.setCustomCss(data: data)
    }
}
