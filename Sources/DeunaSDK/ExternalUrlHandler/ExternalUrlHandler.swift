import Foundation
enum ExternalUrlHandlerBrowser {
    case safariView
    case webView
}

class ExternalUrlHandler {
    static let shared = SafariView()
    
    var newTabWebViewController: NewTabWebViewController? = nil
    var isVisible: Bool = false
    var listeners: [VoidCallback] =  []
    var onClosed: VoidCallback? = nil
    
    
    
    func open(
        with url: URL,
        browser: ExternalUrlHandlerBrowser,
        parent: DeunaWebViewController,
        onClosed: @escaping VoidCallback
    ){
        self.isVisible = true
        self.onClosed = onClosed
        switch browser {
        case .safariView:
            SafariView.shared.open(url: url, viewController: parent) {
                // Manual dismissed
                self.handleExternalUrlClosed()
            }
        case.webView:
            newTabWebViewController = NewTabWebViewController(
                url: url,
                onLoadError: { _ in
                    self.closeExternalUrlWebView()
                },
                onViewDestroyed: {
                    self.handleExternalUrlClosed()
                }
            )

            newTabWebViewController?.modalPresentationStyle = .pageSheet
            if let subWebVC = newTabWebViewController {
                parent.present(subWebVC, animated: false)
            }
        }
    }
    
    // Notify when the Safari view was closed
    private func handleExternalUrlClosed(){
        for listener in self.listeners {
            listener()
        }
        listeners.removeAll()
        isVisible = false
        self.onClosed?()
        self.onClosed = nil
        self.newTabWebViewController = nil
    }
    
    // Add a clousure to ensure that the safari view controller was closed
    func waitUntilSafariViewIsClosed(completion: @escaping VoidCallback) {
        if isVisible {
            listeners.append(completion)
        } else {
            completion()
        }
    }

    
    // Closes an external url that was opened in a new web view
    func closeExternalUrlWebView(){
        guard let newTabWebViewController = newTabWebViewController else {
            return
        }
        newTabWebViewController.close()
    }
}
