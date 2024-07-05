import Foundation
import SystemConfiguration
import WebKit

/// Class representing the Deuna SDK.
public class DeunaSDK: NSObject, UIAdaptivePresentationControllerDelegate {
    /// The environment in which the SDK operates.
    let environment: Environment
    
    /// The public API key for the checkout and elements process
    let publicApiKey: String
    
    private static var instance: DeunaSDK?
    
    /// Shared instance of the SDK.
    public static var shared: DeunaSDK {
        return instance!
    }
    
    /// Class to pass the user information to the vault widget when the url is building
    public class UserInfo {
        let firstName: String
        let lastName: String
        let email: String
        
        public init(firstName: String, lastName: String, email: String) {
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
        }
    }
    
    /// Initializes the SDK with the specified environment and API keys.
    ///
    /// - Parameters:
    ///   - environment: The environment in which the SDK operates.
    ///   - publicApiKey: The public API key for the checkout and elements process
    public init(environment: Environment, publicApiKey: String) {
        self.environment = environment
        self.publicApiKey = publicApiKey
    }
    
    /// Registers an unique instance of the Deuna SDK.
    ///
    /// - Parameters:
    ///   - environment: The environment in which the SDK operates.
    ///   - publicApiKey: The public API key for the checkout and elements process
    public static func initialize(environment: Environment, publicApiKey: String) {
        instance = DeunaSDK(
            environment: environment,
            publicApiKey: publicApiKey
        )
    }
    
    // MARK: - Internal
    
    // Web view controller for the checkout process
    var checkoutWebViewController: CheckoutViewController?
    
    // Web view controller for SDK elements
    var elementsWebViewController: ElementsViewController?
    
    // Web view controller for the Payment Widget
    var paymentWidgetViewController: PaymentWidgetViewController?
}
