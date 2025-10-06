import DEUNAClient
import Foundation
import SwiftUI
import WebKit

/// Custom configurations for the widge
public class ElementsWidgetExperience {
    let userExperience: UserExperience
    
    public init(userExperience: UserExperience) {
        self.userExperience = userExperience
    }
    
    public class UserExperience {
        let showSavedCardFlow: Bool?
        let defaultCardFlow: Bool?
        
        public init(showSavedCardFlow: Bool? = nil, defaultCardFlow: Bool? = nil) {
            self.showSavedCardFlow = showSavedCardFlow
            self.defaultCardFlow = defaultCardFlow
        }
    }
}

/// Extension of DeunaSDK to handle elements-related functionalities.
public extension DeunaSDK {
    /// Initializes and show the elements widget.
    ///
    /// - Parameters:
    ///   - userToken: The token representing the user.
    ///   - callbacks: The callbacks to handle elements events.
    ///   - closeEvents: A Set of ElementsEvent values specifying when to close the elements process automatically.
    ///   - userInfo: (Optional) The basic user information. Pass this parameter if the userToken parameter is null.
    ///   - styleFile: (Optional) An UUID provided by DEUNA. This applies if you want to set up a custom style file.
    ///   - types: (Optional)  A list of the widgets to be rendered. By default the Vault widget will be showed.
    ///   - language: (Optional)  A language code (Example: es, pt, en)
    ///   - orderToken: (Optional) The orderToken is a unique token generated for the payment order. This token is generated through the DEUNA API and you must implement the corresponding endpoint in your backend to obtain this information.
    ///   - widgetExperience: (Optional)  A instance of ElementsWidgetExperience that contains a custom configurations for the widget.
    ///     The currently supported configurations are:
    ///       - `userExperience.showSavedCardFlow`: (Bool) Shows the saved cards toggle.
    ///       - `userExperience.defaultCardFlow`: (Bool) Shows the toggle to save the card as default.
    ///
    ///     Example:
    ///     ```
    ///     ElementsWidgetExperience(
    ///         userExperience: ElementsWidgetExperience.UserExperience(
    ///             showSavedCardFlow: true,
    ///             defaultCardFlow: true
    ///         )
    ///     )
    ///     ```
    func initElements(
        userToken: String? = nil,
        callbacks: ElementsCallbacks,
        closeEvents: Set<ElementsEvent> = [],
        userInfo: UserInfo? = nil,
        styleFile: String? = nil,
        types: [Json] = [],
        language: String? = nil,
        orderToken: String? = nil,
        widgetExperience: ElementsWidgetExperience? = nil,
        behavior: Json? = nil
    ) {
        let link = buildElementsURL(
            userToken: userToken,
            callbacks: callbacks,
            closeEvents: closeEvents,
            userInfo: userInfo,
            styleFile: styleFile,
            types: types,
            language: language,
            orderToken: orderToken,
            widgetExperience: widgetExperience,
            behavior: behavior
        )
        
        if link == nil {
            return
        }
          
        // Initialize the elements web view controller with the provided callbacks and close events
        deunaWebViewController = ElementsViewController(callbacks: callbacks, closeEvents: closeEvents)
        
        // Show the elements web view controller
        if !showWebView(webViewController: deunaWebViewController!) {
            return
        }
        
        // Check for internet connectivity
        guard NetworkUtils.hasInternet else {
            callbacks.onError?(ElementsVaultWidgetErrors.noInternetConnection)
            return
        }
        
        DeunaLogs.debug("Loading elements link: \(link!)")
        deunaWebViewController?.loadUrl(urlString: link!)
    }
    
    @available(iOS 13.0, *)
    func elementsWidget(
        configuration: ElementsWidgetConfiguration
    ) -> some View {
        deunaWebViewController = ElementsViewController(
            callbacks: configuration.callbacks,
            closeEvents: configuration.closeEvents,
            hidePayButton: configuration.hidePayButton,
            isEmbeddedWidget: true
        )
       
        let link = buildElementsURL(
            userToken: configuration.userToken,
            callbacks: configuration.callbacks,
            closeEvents: configuration.closeEvents,
            userInfo: configuration.userInfo,
            styleFile: configuration.styleFile,
            types: configuration.types,
            language: configuration.language,
            orderToken: configuration.orderToken,
            widgetExperience: configuration.widgetExperience,
            behavior: configuration.behavior,
            integration: .embedded
        )
        
        if let link = link {
            deunaWebViewController?.loadUrl(urlString: link)
            DeunaLogs.debug("Loading elements link: \(link)")
        }
        
        return DeunaWebViewRepresentable(webViewController: deunaWebViewController!)
    }
    
    private func buildElementsURL(
        userToken: String? = nil,
        callbacks: ElementsCallbacks,
        closeEvents: Set<ElementsEvent> = [],
        userInfo: UserInfo? = nil,
        styleFile: String? = nil,
        types: [Json] = [],
        language: String? = nil,
        orderToken: String? = nil,
        widgetExperience: ElementsWidgetExperience? = nil,
        behavior: Json? = nil,
        integration: WidgetIntegration? = .modal
    ) -> String? {
        var queryParameters = [
            (QueryParameters.mode, QueryParameters.widget),
            (QueryParameters.publicApiKey, publicApiKey),
            (QueryParameters.int, integration?.rawValue ?? "modal")
        ]
        
        if let language = language {
            queryParameters.append((QueryParameters.language, language))
        }
        
        if let styleFile = styleFile, !styleFile.isEmpty {
            queryParameters.append((QueryParameters.cssFile, styleFile)) // should be removed in the future versions
            queryParameters.append((QueryParameters.styleFile, styleFile))
        }
        
        if let orderToken = orderToken, !orderToken.isEmpty {
            queryParameters.append((QueryParameters.orderToken, orderToken))
        }
        
        if let widgetExperience = widgetExperience {
            if let showSavedCardFlow = widgetExperience.userExperience.showSavedCardFlow {
                queryParameters.append((QueryParameters.showSavedCardFlow, "\(showSavedCardFlow)"))
            }
            if let defaultCardFlow = widgetExperience.userExperience.defaultCardFlow {
                queryParameters.append((QueryParameters.defaultCardFlow, "\(defaultCardFlow)"))
            }
        }
          
        /// if the userToken is passed and it is not empty, it will be added to the url in query parameters
        if let userToken = userToken, !userToken.isEmpty {
            queryParameters.append((QueryParameters.userToken, userToken))
        }
        
        if let userInfo = userInfo {
            guard userInfo.isValidUserInfo else {
                DeunaLogs.error(ElementsErrorMessages.invalidUserInfo)
                callbacks.onError?(ElementsVaultWidgetErrors.invalidUserInfo)
                return nil
            }
            queryParameters.append((QueryParameters.firstName, userInfo.firstName))
            queryParameters.append((QueryParameters.lastName, userInfo.lastName))
            queryParameters.append((QueryParameters.email, userInfo.email.encodeValue()))
        }
        
        var xprops: Json = [:]
        
        if let behavior = behavior {
            xprops[QueryParameters.behavior] = behavior
        }
        
        if !xprops.isEmpty {
            queryParameters.append((QueryParameters.xpropsB64, xprops.base64String() ?? ""))
        }
        
        // Construct the base URL for elements and the URL string
        // by default the VAULT widget is showed if the types list is empty
        let widgetName = types.first?[ElementsTypeKey.name] as? String ?? ElementsWidget.vault
        let baseUrl = "\(environment.config.elementsBaseUrl)/\(widgetName)"
               
        guard let link = buildUrl(baseUrl: baseUrl, queryParameters: queryParameters) else {
            callbacks.onError?(ElementsVaultWidgetErrors.linkCouldNotBeGenerated)
            return nil
        }
        return link
    }

    /// Closes the elements process if it is currently active.
    @available(*, deprecated, message: "Use close function instead.", renamed: "close")
    func closeElements() {
        close()
    }
}
