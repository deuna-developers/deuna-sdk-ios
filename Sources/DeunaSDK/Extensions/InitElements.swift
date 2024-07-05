import DEUNAClient
import Foundation
import WebKit

extension DeunaSDK.UserInfo {
    var isValidFirstName: Bool {
        return !firstName.isEmpty
    }
      
    var isValidLastName: Bool {
        return !lastName.isEmpty
    }
      
    var isValidEmail: Bool {
        let emailRegEx = "^(?:[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+))$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
      
    var isValidUserInfo: Bool {
        return isValidFirstName && isValidLastName && isValidEmail
    }
}

/// Extension of DeunaSDK to handle elements-related functionalities.
public extension DeunaSDK {
    /// Initializes the elements process.
    ///
    /// - Parameters:
    ///   - userToken: The token representing the user.
    ///   - callbacks: The callbacks to handle elements events.
    ///   - closeEvents: A Set of ElementsEvent values specifying when to close the elements process automatically.
    func initElements(
        userToken: String? = nil,
        callbacks: ElementsCallbacks,
        closeEvents: Set<ElementsEvent> = [],
        userInfo: UserInfo? = nil
    ) {
        // Construct the base URL for elements and the URL string
        let baseUrl = "\(environment.baseUrls.elementsBaseUrl)/vault"
        
        guard var urlComponents = URLComponents(string: baseUrl) else {
            handleElementsError(.vaultFailed, callbacks: callbacks)
            return
        }
        
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: QueryParameters.publicApiKey, value: publicApiKey))
        queryParameters.append(URLQueryItem(name: QueryParameters.mode, value: QueryParameters.widget))
          
        let useUserToken = userToken?.isEmpty == false
        /// if the userToken is passed and it is not empty, it will be added to the url in query parameters
        if useUserToken {
            queryParameters.append(URLQueryItem(name: QueryParameters.userToken, value: userToken))
        } else if let userInfo = userInfo {
            guard userInfo.isValidUserInfo else {
                DeunaLogs.error("Invalid instance of UserInfo: check the firstName, lastName and email fields")
                handleElementsError(.vaultFailed, callbacks: callbacks)
                return
            }
        } else {
            // if the user token is not passed or is empty the userInfo must be passed
            DeunaLogs.error("userToken or userInfo must be passed")
            handleElementsError(.vaultFailed, callbacks: callbacks)
            return
        }
        
        if userInfo != nil {
            queryParameters.append(
                URLQueryItem(
                    name: QueryParameters.firstName,
                    value: userInfo!.firstName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                )
            )
            queryParameters.append(
                URLQueryItem(
                    name: QueryParameters.lastName,
                    value: userInfo!.lastName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                )
            )
            queryParameters.append(
                URLQueryItem(
                    name: QueryParameters.email,
                    value: userInfo!.email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                )
            )
        }
               
        urlComponents.queryItems = queryParameters
        guard let link = urlComponents.url?.absoluteString else {
            handleElementsError(.vaultFailed, callbacks: callbacks)
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
            handleElementsError(.noInternetConnection, callbacks: callbacks)
            return
        }
        
        // Set the presentation controller delegate and load the elements URL
        elementsWebViewController?.presentationController?.delegate = self
        DeunaLogs.debug("Loading elements link: \(link)")
        elementsWebViewController?.loadUrl(urlString: link)
    }

    /// Closes the elements process if it is currently active.
    func closeElements() {
        guard let elementsVC = elementsWebViewController, elementsVC.isViewLoaded, elementsVC.view.window != nil else {
            return
        }
        elementsVC.closeWebView()
    }
    
    /// Method to handle SDK errors.
    private func handleElementsError(
        _ errorType: ElementsErrorType,
        callbacks: ElementsCallbacks
    ) {
        let error = ElementsError(type: errorType)
        callbacks.onError?(error)
    }
}
