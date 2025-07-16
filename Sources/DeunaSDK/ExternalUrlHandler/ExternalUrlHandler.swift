import Foundation
enum ExternalUrlHandlerBrowser {
    case safariView
    case webView
}

class ExternalUrlHandler {
    var newTabWebViewController: NewTabWebViewController? = nil
    var isVisible: Bool = false
    
    
    func open(with url: URL, browser: ExternalUrlHandlerBrowser, parent: DeunaWebViewController){
        self.isVisible = true
        switch browser {
        case .safariView:
            SafariView.shared.open(url: url, viewController: parent) {
                // Manual dismissed
                self.isVisible = false
            }
        case.webView:
            newTabWebViewController = NewTabWebViewController(
                url: url,
                onLoadError: { _ in
                    self.close()
                },
                onViewDestroyed: {
                    self.newTabWebViewController = nil
                    self.isVisible = false
                }
            )

            newTabWebViewController?.modalPresentationStyle = .pageSheet
            if let subWebVC = newTabWebViewController {
                parent.present(subWebVC, animated: false)
            }
        }
    }
    
    
    func close(){
        newTabWebViewController?.close()
        newTabWebViewController = nil
        SafariView.shared.close()
        self.isVisible = false
    }
}
