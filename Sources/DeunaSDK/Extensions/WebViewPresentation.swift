//
//  File.swift
//
//
//  Created by Darwin Morocho on 8/3/24.
//

import Foundation
import UIKit

extension DeunaSDK {
    /// Method to show a web view as a modal
    /// - Parameter webViewController: The web view controller to be shown.
    /// - Returns: `true` if the web view controller was successfully shown, `false` if it failed to show.
    func showWebView(webViewController: BaseWebViewController) -> Bool {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            DeunaLogs.warning("Modal could not be showed, rootViewController is null")
            return false
        }
        
        webViewController.modalPresentationStyle = .pageSheet
        webViewController.presentationController?.delegate = self
        rootViewController.present(webViewController, animated: true, completion: nil)
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
