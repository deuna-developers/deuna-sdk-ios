//
//  SubWebViewHandler.swift
//  DeunaSDK
//
//  Created by DEUNA on 21/10/24.
//

import Foundation

extension DeunaWebViewController {
    func openInNewTab(urlString: String) {
        /// Prevents duplicated tabs
        if newTabWebViewController != nil { return }

        newTabWebViewController = NewTabWebViewController(
            url: URL(string: urlString)!,
            onLoadError: { code in
                self.onLoadError(
                    code: code,
                    message: LoadUrlErrorMessages.getMessage(code: code)
                )
            },
            onViewDestroyed: {
                guard self.newTabWebViewController != nil else { return }
                self.webView?.evaluateJavaScript("""
                       if(!window.onEmbedEvent){
                         console.log('window.onEmbedEvent is not defined');
                       } else {
                         window.onEmbedEvent('\(OnEmbedEvents.apmClosed)');
                       }
                """)
                self.newTabWebViewController = nil
            }
        )

        newTabWebViewController?.modalPresentationStyle = .pageSheet
        if let subWebVC = newTabWebViewController {
            present(subWebVC, animated: false)
        }
    }

    /// Closes the sub web view
    func closeSubWebViewController() {
        newTabWebViewController?.close()
        newTabWebViewController = nil
    }
}
