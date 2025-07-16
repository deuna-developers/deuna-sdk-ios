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
    func showWebView(webViewController: DeunaWebViewController) -> Bool {
        guard let viewController = UIApplication.getTopViewController() else {
            DeunaLogs.warning("Modal could not be showed, viewController is null")
            return false
        }

        DeunaTasks.run {
            webViewController.modalPresentationStyle = .pageSheet
            webViewController.onWidgetClosed = self.onWidgetClosed
            viewController.present(webViewController, animated: true, completion: nil)
            UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        }
        return true
    }

    /// Called when the web view was dismissed
    public func onWidgetClosed() {
        guard let controller = deunaWebViewController else {
            return
        }
        

        switch controller {
        case let checkout as CheckoutViewController:
            checkout.callbacks.onClosed?(controller.closeAction)
        case let paymentWidget as PaymentWidgetViewController:
            paymentWidget.callbacks.onClosed?(controller.closeAction)
        case let vault as ElementsViewController:
            vault.callbacks.onClosed?(controller.closeAction)
        case let voucher as VoucherViewController:
            voucher.callbacks.onClosed?(controller.closeAction)
        case let nextAction as NextActionViewController:
            nextAction.callbacks.onClosed?(controller.closeAction)
        default:
            break
        }

        deunaWebViewController = nil

        UserDefaults.standard.set(true, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
}
