import Foundation

public extension DeunaSDK {
    /// Initializes the payment process using the DEUNA payment widget.
    ///
    /// - Parameters:
    ///   - orderToken: The token representing the order.
    ///   - callbacks: The callbacks to handle payment events.
    ///   - userToken: (Optional) A user authentication token that allows skipping the OTP flow and shows the user's saved cards.
    ///   - styleFile: (Optional) An UUID provided by DEUNA. This applies if you want to set up a custom style file.
    ///   - paymentMethods: (Optional) A list of allowed payment methods.
    ///   Example:
    ///   [
    ///        {
    ///         "payment_method": "my_payment_method",
    ///         "processors" : ["daviplata", "nequi_push_voucher"]
    ///        }
    ///   ]
    ///   - checkoutModules: (Optional) A list  display the payment widget with new patterns or with different functionalities
    ///   Example:
    ///   [
    ///        { "name" : "module_name" }
    ///   ]
    ///   - language: (Optional)  A language code (Example: es, pt, en)
    func initPaymentWidget(
        orderToken: String,
        callbacks: PaymentWidgetCallbacks,
        userToken: String? = nil,
        styleFile: String? = nil,
        paymentMethods: [[String: Any]] = [],
        checkoutModules: [[String: Any]] = [],
        language: String? = nil
    ) {
        guard !orderToken.isEmpty else {
            DeunaLogs.error(PaymentsErrorMessages.orderTokenMustNotBeEmpty)
            callbacks.onError?(PaymentWidgetErrors.invalidOrderToken)
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
            callbacks.onError?(PaymentWidgetErrors.noInternetConnection)
            return
        }
        
        // Construct the base URL for the payment widget
        let baseUrl = "\(environment.baseUrls.paymentWidgetBaseUrl)/now/\(orderToken)"
        
        var queryParameters = [
            (QueryParameters.mode, QueryParameters.widget)
        ]
        
        if let language = language {
            queryParameters.append((QueryParameters.language, language))
        }
        
        if let userToken = userToken, !userToken.isEmpty {
            queryParameters.append((QueryParameters.userToken, userToken))
        }
        
        if let styleFile = styleFile, !styleFile.isEmpty {
            queryParameters.append((QueryParameters.styleFile, styleFile))
        }
        
        var xprops: [String: Any] = [:]
        xprops[QueryParameters.publicApiKey] = publicApiKey
        
        if !paymentMethods.isEmpty {
            xprops[QueryParameters.paymentMethods] = paymentMethods
        }
        
        if !checkoutModules.isEmpty {
            xprops[QueryParameters.checkoutModules] = checkoutModules
        }
        
        queryParameters.append((QueryParameters.xpropsB64, xprops.base64String() ?? ""))
               
        guard let link = buildUrl(baseUrl: baseUrl, queryParameters: queryParameters) else {
            callbacks.onError?(PaymentWidgetErrors.linkCouldNotBeGenerated)
            return
        }
        
        DeunaLogs.debug("Loading payment widget link: \(link)")
        paymentWidgetViewController?.loadUrl(urlString: link)
    }
    
    /// Closes the payment widget if it is currently active.
    @available(*, deprecated, message: "Use close function instead.", renamed: "close")
    func closePaymentWidget() {
        close()
    }
    
    /// Set custom CSS on the payment widget.
    /// This function must be only called inside the next callbacks onCardBinDetected or onInstallmentSelected.
    /// - Parameters:
    ///   - data: The JSON data to update the payment widget UI
    @available(*, deprecated, message: "Use setCustomStyle instead.", renamed: "setCustomStyle")
    func setCustomCss(data: [String: Any]) {
        paymentWidgetViewController?.setCustomCss(data: data)
    }
}
