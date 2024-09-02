import DEUNAClient
import Foundation
import WebKit

/// Extension of DeunaSDK to handle elements-related functionalities.
public extension DeunaSDK {
    /// Initializes and show the elements widget.
    ///
    /// - Parameters:
    ///   - userToken: The token representing the user.
    ///   - callbacks: The callbacks to handle elements events.
    ///   - closeEvents: A Set of ElementsEvent values specifying when to close the elements process automatically.
    ///   - userInfo: (Optional) The basic user information. Pass this parameter if the userToken parameter is null.
    ///   - cssFile: (Optional) An UUID provided by DEUNA. This applies if you want to set up a custom CSS file.
    ///   - types: (Optional)  A list of the widgets to be rendered. By default the Vault widget will be showed.
    func initElements(
        userToken: String? = nil,
        callbacks: ElementsCallbacks,
        closeEvents: Set<ElementsEvent> = [],
        userInfo: UserInfo? = nil,
        cssFile: String? = nil,
        types: [Json] = []
    ) {
        var queryParameters: [String: String] = [
            QueryParameters.mode: QueryParameters.widget,
            QueryParameters.publicApiKey: publicApiKey
        ]
        
        if let cssFile = cssFile, !cssFile.isEmpty {
            queryParameters[QueryParameters.cssFile] = cssFile
        }
          
        let useUserToken = userToken?.isEmpty == false
        /// if the userToken is passed and it is not empty, it will be added to the url in query parameters
        if useUserToken {
            queryParameters[QueryParameters.userToken] = userToken
        } else if let userInfo = userInfo {
            guard userInfo.isValidUserInfo else {
                DeunaLogs.error(ElementsErrorMessages.invalidUserInfo)
                callbacks.onError?(ElementsVaultWidgetErrors.invalidUserInfo)
                return
            }
            queryParameters[QueryParameters.firstName] = userInfo.firstName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            queryParameters[QueryParameters.lastName] = userInfo.lastName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        } else {
            // if the user token is not passed or is empty the userInfo must be passed
            DeunaLogs.error(ElementsErrorMessages.missingUserTokenOrUserInfo)
            callbacks.onError?(ElementsVaultWidgetErrors.missingUserTokenOrUserInfo)
            return
        }
        
        // Construct the base URL for elements and the URL string
        // by default the VAULT widget is showed if the types list is empty
        let widgetName = types.first?[ElementsTypeKey.name] as? String ?? ElementsWidget.vault
        let baseUrl = "\(environment.baseUrls.elementsBaseUrl)/\(widgetName)"
               
        guard var link = buildUrl(baseUrl: baseUrl, queryParameters: queryParameters) else {
            callbacks.onError?(ElementsVaultWidgetErrors.linkCouldNotBeGenerated)
            return
        }
        
        // Initialize the elements web view controller with the provided callbacks and close events
        elementsWebViewController = ElementsViewController(callbacks: callbacks, closeEvents: closeEvents)
        
        // Show the elements web view controller
        if !showWebView(webViewController: elementsWebViewController!) {
            return
        }
        
        // Check for internet connectivity
        guard NetworkUtils.hasInternet else {
            callbacks.onError?(ElementsVaultWidgetErrors.noInternetConnection)
            return
        }
        
        // Set the presentation controller delegate and load the elements URL
        elementsWebViewController?.presentationController?.delegate = self
        
        if let email = userInfo?.email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.replacingOccurrences(of: "+", with: "%2B").replacingOccurrences(of: "@", with: "%40") {
            link = "\(link)&email=\(email)"
        }
        
        DeunaLogs.debug("Loading elements link: \(link)")
        
        elementsWebViewController?.loadUrl(urlString: link)
    }

    /// Closes the elements process if it is currently active.
    @available(*, deprecated, message: "Use close function instead.", renamed: "close")
    func closeElements() {
        close()
    }
}
