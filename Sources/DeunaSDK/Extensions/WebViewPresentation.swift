//
//  File.swift
//
//
//  Created by Darwin Morocho on 8/3/24.
//

import Foundation
import UIKit


/// For swift 4 / 5 + to get topmost viewController
extension UIApplication {
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopViewController(base: selected)
            }
        }

        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }

        return base
    }
}

extension DeunaSDK {
    /// Method to show a web view as a modal
    /// - Parameter webViewController: The web view controller to be shown.
    /// - Returns: `true` if the web view controller was successfully shown, `false` if it failed to show.
    func showWebView(webViewController: BaseWebViewController) -> Bool {
        
        guard let viewController = UIApplication.getTopViewController() else {
            DeunaLogs.warning("Modal could not be showed, viewController is null")
            return false
        }
        
        webViewController.modalPresentationStyle = .pageSheet
        webViewController.presentationController?.delegate = self
        viewController.present(webViewController, animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        return true
    }
    
    /// Method called when the webView modal is dismissed.
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let checkout = checkoutWebViewController {
            // the modal was dismised by user
            if !checkout.closeWebviewWasCalled {
                checkout.callbacks.onCanceled?()
            }
            checkout.callbacks.onClosed?()
        }
        
        if let paymentWidget = paymentWidgetViewController {
            if !paymentWidget.closeWebviewWasCalled {
                paymentWidget.callbacks.onCanceled?()
            }
            paymentWidget.callbacks.onClosed?()
        }
        
        if let elements = elementsWebViewController {
            // the modal was dismised by user
            if !elements.closeWebviewWasCalled {
                elements.callbacks.onCanceled?()
            }
            elements.callbacks.onClosed?()
        }
  
        elementsWebViewController = nil
        checkoutWebViewController = nil
        paymentWidgetViewController = nil
        
        UserDefaults.standard.set(true, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
}
