//
//  initNextAction.swift
//  DeunaSDK
//
//  Created by deuna on 4/4/25.
//

import SwiftUI

extension DeunaSDK {
    public func initNextAction(
        orderToken: String,
        callbacks: NextActionCallbacks,
        language: String? = nil
    ) {
        guard !orderToken.isEmpty else {
            DeunaLogs.error(PaymentsErrorMessages.orderTokenMustNotBeEmpty)
            callbacks.onError?(PaymentWidgetErrors.invalidOrderToken)
            return
        }
        
        deunaWebViewController = NextActionViewController(callbacks: callbacks)
        // Check for internet connectivity
        guard NetworkUtils.hasInternet else {
            callbacks.onError?(PaymentWidgetErrors.noInternetConnection)
            return
        }
        
        // Show the elements web view controller
        if !showWebView(webViewController: deunaWebViewController!) {
            return
        }
        
        guard let link = buildNextActionURL(
            orderToken: orderToken,
            language: language
        ) else {
            callbacks.onError?(PaymentWidgetErrors.linkCouldNotBeGenerated)
            return
        }
        
        DeunaLogs.debug("Loading payment widget link: \(link)")
        deunaWebViewController?.loadUrl(urlString: link)
    }
    
    
    @available(iOS 13.0, *)
    func nextActionWidget(
        configuration: NextActionWidgetConfiguration
    ) -> some View {
        deunaWebViewController = NextActionViewController(
            callbacks: configuration.callbacks,
            isEmbeddedWidget: true
        )
       
        let url = self.buildNextActionURL(
            orderToken: configuration.orderToken,
            language: configuration.language,
            integration: .embedded
        )
        
        if let urlString = url {
            deunaWebViewController?.loadUrl(urlString: urlString)
            DeunaLogs.debug("Loading payment widget link: \(urlString)")
        }
        return DeunaWebViewRepresentable(webViewController: deunaWebViewController!)
    }
    
    
    ///  Build the payment widget URL
    private func buildNextActionURL(
        orderToken: String,
        language: String? = nil,
        integration: WidgetIntegration? = .modal
    ) -> String? {
        // Construct the base URL for the payment widget
        let baseUrl = "\(environment.config.paymentWidgetBaseUrl)/next-action-purchase/\(orderToken)"
        
        var queryParameters = [
            (QueryParameters.mode, QueryParameters.widget),
            (QueryParameters.int, integration?.rawValue ?? "modal")
        ]
        
        if let language = language {
            queryParameters.append((QueryParameters.language, language))
        }
        
        return buildUrl(baseUrl: baseUrl, queryParameters: queryParameters)
    }
}
