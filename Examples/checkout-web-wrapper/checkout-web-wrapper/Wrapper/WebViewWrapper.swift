import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    let onJavascriptMesaageReceived: (JavaScriptMessage) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        let coordinator = makeCoordinator()
        contentController.add(coordinator, name: "deunaPayment")
        config.userContentController = contentController
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator(
            onExternalURLOpened: ExternalUrlHelper.shared.open,
            onJavaScriptMessageReceived: { message in
                switch message.callbackName {
                case .onSuccess,.onError:
                    ExternalUrlHelper.shared.close()
                    break
                default:
                    break
                }
                onJavascriptMesaageReceived(message)
            }
        )
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
