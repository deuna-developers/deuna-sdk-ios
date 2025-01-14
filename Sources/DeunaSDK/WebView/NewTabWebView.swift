//
//  File.swift
//
//
//  Created by Darwin Morocho on 28/3/24.
//

import Foundation
@preconcurrency import WebKit

class NewTabWebViewController: BaseWebViewController, DeunaWebViewDelegate, WKScriptMessageHandler {
    private let url: URL
    private let onLoadError: (Int) -> Void
    private let onViewDestroyed: () -> Void
    
    private let configuration = WKWebViewConfiguration()
    var activityIndicator: UIActivityIndicatorView?
    
    private var closeHandler = ""
    private var openInNewTabHandler = ""

    init(url: URL, onLoadError: @escaping (Int) -> Void, onViewDestroyed: @escaping () -> Void) {
        self.url = url
        self.onLoadError = onLoadError
        self.onViewDestroyed = onViewDestroyed
        // Call super.init to initialize UIViewController first
        super.init(openRequestNavigationsInNewTab: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        loadUrl()
        showLoader()
    }
    /// Shows the activity indicator loader.
    func showLoader() {
        
        if activityIndicator != nil {
            return
        }
  
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator!.center = view.center
        view.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
    }
    
    /// Hides the activity indicator loader.
    func hideLoader() {
        guard activityIndicator != nil else { return }
        activityIndicator!.removeFromSuperview()
        activityIndicator = nil
    }

    private func loadUrl() {
        let currentDate = Date()
        let millisecondsSinceEpoch = Int(currentDate.timeIntervalSince1970 * 1000)
        
        /// creates an unique closeHandler name
        closeHandler = "\(WebViewUserContentControllerNames.closeWindow)\(millisecondsSinceEpoch)"
        
        let userScript = WKUserScript(
            source: """
            window.close = function() {
                window.webkit.messageHandlers.\(closeHandler).postMessage("");
            };
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        configuration.userContentController.add(self, name: closeHandler)
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.userContentController.addUserScript(userScript)
        
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        view.addSubview(webView!)
        deunaDelegate = self

        let request = URLRequest(url: url)
        webView?.load(request)
    }

    private func addDismissLineBar() {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.frame = CGRect(
            x: Int(view.frame.width * 0.5) - 40,
            y: 0,
            width: 80,
            height: 30
        )
        
        let lineBarHeight = 6
        let lineBar = UIView()
        lineBar.backgroundColor = .lightGray
        lineBar.frame = CGRect(
            x: Int(view.frame.width * 0.5) - 20,
            y: 10,
            width: 40,
            height: lineBarHeight
        )
        lineBar.layer.cornerRadius = 3
        view.addSubview(containerView)
        view.addSubview(lineBar)
    }
    
    func onWebViewLoaded() {
        webView!.frame.size.height = view.frame.height
        view.translatesAutoresizingMaskIntoConstraints = false
        webView!.scrollView.isScrollEnabled = true
        addDismissLineBar()
        hideLoader()
        
        webView?.evaluateJavaScript("""
            (function() {
                setTimeout(function() {
                    var button = document.getElementById("cash_efecty_button_print");
                    if (button) {
                        button.style.display = "none";
                    }
                }, 500); // time out 500 ms
            })();
        """, completionHandler: { _, error in
            if let error = error {
                DeunaLogs.error("Error hide button JavaScript: \(error.localizedDescription)")
            }
        })
    }
    
    func onWebviewError(_ errorCode: Int) {
        onLoadError(errorCode)
    }
    
    func onOpenInNewTab(_ url: URL) {
        if url.isFileDownloadUrl {
            showLoader()
            downloadFile(urlString: url.absoluteString){
                self.hideLoader()
            }
        }
    }
    
    func onDownloadFile(_ url: URL) {
        showLoader()
        downloadFile(urlString: url.absoluteString){
            self.hideLoader()
        }
    }

    func close() {
        dismiss(animated: false)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case closeHandler:
            close() // Closed the current UIViewController when window.close is called
            
        default:
            DeunaLogs.info(message.name)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.removeFromSuperview()
        webView?.stopLoading()
        webView = nil
        onViewDestroyed()
        super.viewDidDisappear(animated)
    }
}
