import DEUNAClient
import Foundation
import SwiftUICore
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
    ///   - language: (Optional)  A language code (Example: es, pt, en)
    func initCheckout(
        orderToken: String,
        callbacks: CheckoutCallbacks,
        closeEvents: Set<CheckoutEvent> = [],
        userToken: String? = nil,
        styleFile: String? = nil,
        language: String? = nil
    ) {
        guard !orderToken.isEmpty else {
            DeunaLogs.error(PaymentsErrorMessages.orderTokenMustNotBeEmpty)
            callbacks.onError?(PaymentWidgetErrors.invalidOrderToken)
            return
        }
        
        // Initialize the checkout web view controller with the provided callbacks and close events
        deunaWebViewController = CheckoutViewController(callbacks: callbacks, closeEvents: closeEvents)

        // Show the checkout web view controller
        if !showWebView(webViewController: deunaWebViewController!) {
            return
        }
        
        // Check for internet connectivity
        guard NetworkUtils.hasInternet else {
            callbacks.onError?(PaymentWidgetErrors.noInternetConnection)
            return
        }
        
        buildCheckoutURL(
            orderToken: orderToken,
            callbacks: callbacks,
            closeEvents: closeEvents,
            userToken: userToken,
            styleFile: styleFile,
            language: language
        )
    }
    
    @available(iOS 13.0, *)
    func checkoutWidget(
        configuration: CheckoutWidgetConfiguration
    ) -> some View {
        DeunaLogs.info("Build Checkout Widget")
        
        // Initialize the checkout web view controller with the provided callbacks and close events
        deunaWebViewController = CheckoutViewController(
            callbacks: configuration.callbacks,
            closeEvents: configuration.closeEvents,
            hidePayButton: configuration.hidePayButton,
            isEmbeddedWidget: true
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.buildCheckoutURL(
                orderToken: configuration.orderToken,
                callbacks: configuration.callbacks,
                closeEvents: configuration.closeEvents,
                userToken: configuration.userToken,
                styleFile: configuration.styleFile,
                language: configuration.language,
                integration: .embedded
            )
        }
        
        return DeunaWebViewRepresentable(webViewController: deunaWebViewController!)
    }
    
    private func buildCheckoutURL(
        orderToken: String,
        callbacks: CheckoutCallbacks,
        closeEvents: Set<CheckoutEvent> = [],
        userToken: String? = nil,
        styleFile: String? = nil,
        language: String? = nil,
        integration: WidgetIntegration? = .modal
    ) {
        // Fetch order details using a dedicated error handling function
        fetchOrderDetails(orderToken: orderToken) { response, error in
            if let error = error {
                DeunaLogs.warning(error.localizedDescription)
                callbacks.onError?(PaymentWidgetErrors.orderCouldNotBeRetrieved)
                return
            }

            // Load the payment link if available
            if let order = response?["order"] as? Json, let paymentLink = order["payment_link"] as? String, !paymentLink.isEmpty {
                // START Building the checkout url using the userToken
                var queryParameters: [(String, String)] = []
                queryParameters.append((QueryParameters.mode, QueryParameters.widget))
                queryParameters.append((QueryParameters.int, integration?.rawValue ?? "modal"))
                
                if let language = language {
                    queryParameters.append((QueryParameters.language, language))
                }
                
                if let userToken = userToken, !userToken.isEmpty {
                    queryParameters.append((QueryParameters.userToken, userToken))
                }
                
                if let styleFile = styleFile, !styleFile.isEmpty {
                    queryParameters.append((QueryParameters.styleFile, styleFile))
                }
                       
                guard let link = buildUrl(baseUrl: paymentLink, queryParameters: queryParameters) else {
                    callbacks.onError?(PaymentWidgetErrors.linkCouldNotBeGenerated)
                    return
                }
                
                DeunaLogs.debug("Loading payment link: \(link)")
                self.deunaWebViewController?.loadUrl(urlString: link)
            } else {
                callbacks.onError?(PaymentWidgetErrors.linkCouldNotBeGenerated)
            }
        }
    }
    
    // Fetch order details using the provided order token and private API key
    private func fetchOrderDetails(orderToken: String, completion: @escaping (Json?, Error?) -> Void) {
        guard let url = URL(string: "\(environment.config.checkoutBaseUrl)/merchants/orders/\(orderToken)") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(publicApiKey, forHTTPHeaderField: "X-Api-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }
                   
                guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
                    completion(nil, nil)
                    return
                }
                   
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? Json {
                            return completion(json, nil)
                        } else {
                            return completion(nil, nil)
                        }
                    } catch {
                        return completion(nil, error)
                    }
                }
            }
        }

        task.resume()
    }
    
    /// Closes the checkout process if it is currently active.
    @available(*, deprecated, message: "Use close function instead.", renamed: "close")
    func closeCheckout() {
        close()
    }
}
