import Foundation
import SwiftUI
import SystemConfiguration
import WebKit

/// Class representing the Deuna SDK.
public class DeunaSDK: NSObject {
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
    public init(environment: Environment, publicApiKey: String, useMainThread: Bool = false) {
        DeunaTasks.useMainThread = useMainThread
        self.environment = environment
        self.publicApiKey = publicApiKey
    }
    
    /// Registers an unique instance of the Deuna SDK.
    ///
    /// - Parameters:
    ///   - environment: The environment in which the SDK operates.
    ///   - publicApiKey: The public API key for the checkout and elements process
    public static func initialize(environment: Environment, publicApiKey: String, useMainThread: Bool = false) {
        instance = DeunaSDK(
            environment: environment,
            publicApiKey: publicApiKey,
            useMainThread: useMainThread
        )
    }
    
    // MARK: - Internal
    
    // Web view controller for the checkout process
    var checkoutWebViewController: CheckoutViewController?
    
    // Web view controller for SDK elements
    var elementsWebViewController: ElementsViewController?
    
    // Web view controller for the Payment Widget
    var paymentWidgetViewController: PaymentWidgetViewController?
    
    var nextActionViewController: NextActionViewController?
    
    /// Set custom styles on the payment widget, checkout widget or vault widget.
    /// - Parameters:
    ///   - data: The JSON data to update the payment widget UI
    public func setCustomStyle(data: [String: Any]) {
        if let controller = paymentWidgetViewController ?? checkoutWebViewController ?? elementsWebViewController {
            controller.setCustomStyle(data: data)
        }
    }
    
    /// Close the active widget
    public func close() {
        if let controller = paymentWidgetViewController ?? checkoutWebViewController ?? elementsWebViewController ?? nextActionViewController {
            controller.closeWebView(.systemAction)
        }
    }
    
    public func dispose() {
        if let controller = paymentWidgetViewController ?? checkoutWebViewController ?? elementsWebViewController ?? nextActionViewController {
            controller.dispose()
        }
    }
    
    /// Check if the data entered in the widget is valid
    public func isValid(completion: @escaping (Bool) -> Void) {
        if let controller = paymentWidgetViewController ?? checkoutWebViewController ?? elementsWebViewController {
            controller.isValid(completion: completion)
        }
    }
    
    public func refetchOrder(completion: @escaping (Json?) -> Void) {
        if let controller = paymentWidgetViewController ?? checkoutWebViewController ?? elementsWebViewController {
            controller.refetchOrder(completion: completion)
        }
    }
    
    public func submit(completion: @escaping (SubmitResult) -> Void) {
        if let controller = paymentWidgetViewController ?? checkoutWebViewController ?? elementsWebViewController {
            controller.submit(completion: completion)
        }
    }
    
    func getWidgetState(completion: @escaping (Json?) -> Void) {
        if let controller = paymentWidgetViewController ?? checkoutWebViewController ?? elementsWebViewController {
            controller.getWidgetState(completion: completion)
        }
    }
}

@available(iOS 13.0, *)
struct DeunaWebViewRepresentable: UIViewControllerRepresentable {
    let webViewController: DeunaWebViewController

    func makeUIViewController(context: Context) -> DeunaWebViewController {
        return webViewController
    }

    func updateUIViewController(_ uiViewController: DeunaWebViewController, context: Context) {
        // Aquí puedes actualizar si es necesario
    }
}
