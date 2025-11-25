import Foundation
import SwiftUI

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
    ///   - domain: (Optional) A string that replace the deuna baseURL. Example: https://myhost.com or myhost.com
    func initPaymentWidget(
        orderToken: String,
        callbacks: PaymentWidgetCallbacks,
        userToken: String? = nil,
        styleFile: String? = nil,
        paymentMethods: [Json] = [],
        checkoutModules: [Json] = [],
        language: String? = nil,
        behavior: Json? = nil,
        fraudCredentials: Json? = nil,
        domain: String? = nil
    ) {
        guard !orderToken.isEmpty else {
            DeunaLogs.error(PaymentsErrorMessages.orderTokenMustNotBeEmpty)
            callbacks.onError?(PaymentWidgetErrors.invalidOrderToken)
            return
        }
        
        deunaWebViewController = PaymentWidgetViewController(
            sdkConfiguration: self.configuration,
            callbacks: callbacks,
            widgetConfig: WidgetConfig(
                orderToken: orderToken,
                userToken: userToken,
                behavior: behavior
            ),
            fraudCredentials: fraudCredentials,
        )
        
        // Show the elements web view controller
        if !showWebView(webViewController: deunaWebViewController!) {
            return
        }
        
        // Check for internet connectivity
        guard NetworkUtils.hasInternet else {
            callbacks.onError?(PaymentWidgetErrors.noInternetConnection)
            return
        }
        
        guard let link = buildPaymentWidgetURL(
            orderToken: orderToken,
            userToken: userToken,
            styleFile: styleFile,
            paymentMethods: paymentMethods,
            checkoutModules: checkoutModules,
            language: language,
            behavior: behavior,
            domain: domain
        ) else {
            callbacks.onError?(PaymentWidgetErrors.linkCouldNotBeGenerated)
            return
        }
        
        DeunaLogs.debug("Loading payment widget link: \(link)")
        deunaWebViewController?.loadUrl(urlString: link)
    }
    
    @available(iOS 13.0, *)
    func paymentWidget(
        configuration: PaymentWidgetConfiguration
    ) -> some View {
        deunaWebViewController = PaymentWidgetViewController(
            sdkConfiguration: self.configuration,
            callbacks: configuration.callbacks,
            hidePayButton: configuration.hidePayButton,
            isEmbeddedWidget: true,
            widgetConfig: WidgetConfig(
                orderToken: configuration.orderToken,
                userToken: configuration.userToken,
                behavior: configuration.behavior
            ),
            fraudCredentials: configuration.fraudCredentials
        )
       
        let paymentWidgetURL = self.buildPaymentWidgetURL(
            orderToken: configuration.orderToken,
            userToken: configuration.userToken,
            styleFile: configuration.styleFile,
            paymentMethods: configuration.paymentMethods,
            checkoutModules: configuration.checkoutModules,
            language: configuration.language,
            behavior: configuration.behavior,
            integration: .embedded,
            domain: configuration.domain
        )
        
        if let urlString = paymentWidgetURL {
            deunaWebViewController?.loadUrl(urlString: urlString)
            DeunaLogs.debug("Loading payment widget link: \(urlString)")
        }
        return DeunaWebViewRepresentable(webViewController: deunaWebViewController!)
    }
    
    ///  Build the payment widget URL
    private func buildPaymentWidgetURL(
        orderToken: String,
        userToken: String? = nil,
        styleFile: String? = nil,
        paymentMethods: [Json] = [],
        checkoutModules: [Json] = [],
        language: String? = nil,
        behavior: Json? = nil,
        integration: WidgetIntegration? = .modal,
        domain: String? = nil
    ) -> String? {
        // Construct the base URL for the payment widget
        var baseUrl = "\(self.configuration.environment.config.paymentWidgetBaseUrl)/now/\(orderToken)"
        
        if let domain = domain {
            baseUrl = overrideBaseUrl(baseUrl: baseUrl, replaceWith: domain)
        }
        
        var queryParameters = [
            (QueryParameters.mode, QueryParameters.widget),
            (QueryParameters.int, integration?.rawValue ?? "modal")
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
        
        var xprops: Json = [:]
        xprops[QueryParameters.publicApiKey] = self.configuration.publicApiKey
        
        if let behavior = behavior {
            xprops[QueryParameters.behavior] = behavior
        }
        
        if !paymentMethods.isEmpty {
            xprops[QueryParameters.paymentMethods] = paymentMethods
        }
        
        if !checkoutModules.isEmpty {
            xprops[QueryParameters.checkoutModules] = checkoutModules
        }

        queryParameters.append((QueryParameters.xpropsB64, xprops.base64String() ?? ""))
               
        return buildUrl(baseUrl: baseUrl, queryParameters: queryParameters)
    }
}
