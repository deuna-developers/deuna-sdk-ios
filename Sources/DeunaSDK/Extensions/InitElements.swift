import DEUNAClient
import Foundation
import WebKit

/// Extension of DeunaSDK to handle elements-related functionalities.
public extension DeunaSDK {
    /// Initializes the elements process.
    ///
    /// - Parameters:
    ///   - userToken: The token representing the user.
    ///   - callbacks: The callbacks to handle elements events.
    ///   - closeEvents: A Set of ElementsEvent values specifying when to close the elements process automatically.
    func initElements(
        userToken: String,
        callbacks: ElementsCallbacks,
        closeEvents: Set<ElementsEvent> = []
    ) {
        guard !userToken.isEmpty else{
            DeunaLogs.error("userToken must not be empty")
            handleElementsError(.invalidUserToken, callbacks: callbacks)
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
        
        // Construct the base URL for elements and the URL string
        let baseUrl = "\(environment.baseUrls.elementsBaseUrl)/vault"
        let elementURL = "\(baseUrl)?userToken=\(userToken)&publicApiKey=\(publicApiKey)&mode=widget"
        
        // Set the presentation controller delegate and load the elements URL
        elementsWebViewController?.presentationController?.delegate = self
        DeunaLogs.debug("Loading elements link: \(elementURL)")
        elementsWebViewController?.loadUrl(urlString: elementURL)
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
