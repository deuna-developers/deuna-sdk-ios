//
// DeunaSDK+PresentationController.swift
//

import Foundation
import WebKit

extension DeunaSDK: UIAdaptivePresentationControllerDelegate {
    
    internal func presentWebView(viewToEmbedWebView: UIView? = nil) {
        if shouldPresentInModal {
            presentInModal()
        } else {
            embedInView(viewToEmbedWebView: viewToEmbedWebView)
        }
    }
    
    private func presentInModal() {
        let newView = createNewView()
        
        setupConstraintsFor(newView: newView, in: self.webViewController.view)
        
        self.webViewController.modalPresentationStyle = .pageSheet
        self.webViewController.presentationController?.delegate = self
        if let topViewController = getTopViewController() {
            topViewController.present(self.webViewController, animated: true, completion: nil)
        }
        
        assignAndConstrainWebView(to: newView)
    }
    
    // MARK: - Private Methods
    internal func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        // Recursive method to get the topmost view controller
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        }
        
        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        
        return base
    }
    
    private func embedInView(viewToEmbedWebView: UIView? = nil) {
        // If viewToEmbedWebView is not provided, attempt to use the top view controller's view.
        let targetView = viewToEmbedWebView ?? getTopViewController()?.view
        
        // If we still don't have a target view, we need to create one and add it to the window.
        guard let containerView = targetView else {
            print("DeunaSDK Error: No view available to embed the web view.")
            // Optionally, you could create a new window and add the view to it, but this is a rare case.
            return
        }
        
        // Create a new view that will contain the web view.
        let newView = createNewView()
        
        // Add the new view to the container view and set up constraints.
        containerView.addSubview(newView)
        setupConstraintsFor(newView: newView, in: containerView)
        
        // Assign the web view to the new view with constraints.
        assignAndConstrainWebView(to: newView)
        
        print("DeunaSDK: WebView is now embedded or should be visible.")
    }
    
    
    private func createNewView() -> UIView {
        let newView = UIView(frame: CGRect.zero)
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }
    
    private func setupConstraintsFor(newView: UIView, in containerView: UIView) {
        containerView.addSubview(newView)
        NSLayoutConstraint.activate([
            newView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newView.topAnchor.constraint(equalTo: containerView.topAnchor),
            newView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func assignAndConstrainWebView(to newView: UIView) {
        guard let webView = self.DeunaWebView else { return }
        DeunaView = newView
        newView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: newView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: newView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: newView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: newView.bottomAnchor)
        ])
    }
    
    private func initializeLoader() -> UIActivityIndicatorView {
        // Set the loader style based on the iOS version
        let loaderStyle: UIActivityIndicatorView.Style = {
            if #available(iOS 13.0, *) {
                return .large
            } else {
                return .whiteLarge // This is the older equivalent
            }
        }()
        
        let loader = UIActivityIndicatorView(style: loaderStyle)
        let center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        loader.center = center
        loader.hidesWhenStopped = true // This will hide the loader when you call stopAnimating()
        
        return loader
    }

    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        closeCheckout()
    }
    
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return canDismiss()
    }
    
    internal func canDismiss() -> Bool {
        print(self.processing)
        return !self.processing
    }
    
    internal func showCloseButtonInView() {
        if canDismiss()  && showCloseButton{
            // Create and display the close button on the WebView
            let closeButton = self.createCloseButton()
            closeButton.tag = closeButtonTag  // Set the tag
            self.DeunaWebView?.addSubview(closeButton)
            self.DeunaWebView?.bringSubviewToFront(closeButton)
        }
    }

    internal func hideCloseButtonInView() {
        // Find the close button on the WebView using the tag and remove it
        if let closeButton = self.DeunaWebView?.viewWithTag(closeButtonTag) {
            closeButton.removeFromSuperview()
        }
    }
    
    public func hideLoader() {
        // Public method to always hide the loader
        loader?.stopAnimating()
        loader?.removeFromSuperview()
    }
    
    internal func showLoader(){
        // Initialize the loader and start its animation
        self.loader = initializeLoader()
        self.loader?.startAnimating()
        UIApplication.shared.keyWindow?.addSubview(self.loader!)
    }
    
    
}
