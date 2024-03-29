//
// DeunaSDK+PresentationController.swift
//

import Foundation
import WebKit

extension DeunaSDK: UIAdaptivePresentationControllerDelegate {
    
    internal func presentWebView(viewToEmbedWebView: UIView? = nil, webView : WKWebView) {
        if shouldPresentInModal {
            presentInModal(webView : webView)
        } else {
            embedInView(viewToEmbedWebView: viewToEmbedWebView, webView:webView)
        }
    }
    
    private func presentInModal(webView : WKWebView) {
        let newView = createNewView()
  
        if(webView == DeunaWebView){
            setupConstraintsFor(newView: newView, in: self.webViewController.view)
            
            self.webViewController.modalPresentationStyle = .pageSheet
            self.webViewController.presentationController?.delegate = self
            if let topViewController = getTopViewController() {
                topViewController.present(self.webViewController, animated: true, completion: nil)
            }
        }else{
            setupConstraintsFor(newView: newView, in: self.elementsWebViewController.view)
            
            self.elementsWebViewController.modalPresentationStyle = .pageSheet
            self.elementsWebViewController.presentationController?.delegate = self
            if let topViewController = getTopViewController() {
                topViewController.present(self.webViewController, animated: true, completion: nil)
            }
        }
        assignAndConstrainWebView(to: newView, webView:webView)
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
    
    private func embedInView(viewToEmbedWebView: UIView? = nil, webView : WKWebView) {
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
        assignAndConstrainWebView(to: newView, webView:webView)
        
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
    
    private func assignAndConstrainWebView(to newView: UIView,webView : WKWebView) {
        DeunaView = newView
        newView.addSubview(webView)
        webView.scrollView.bounces = false
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
        loader.color = UIColor(hex: 0x7BCCE5)
        
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

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
