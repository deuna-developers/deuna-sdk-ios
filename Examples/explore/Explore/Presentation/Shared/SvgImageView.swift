import SwiftUI
import WebKit

struct SvgImageView: UIViewRepresentable {
    let url: URL
    var size: CGFloat = 36

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.suppressesIncrementalRendering = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: transparent; display: flex; align-items: center; justify-content: center; width: \(Int(size))px; height: \(Int(size))px; overflow: hidden; }
        img { width: 100%; height: 100%; object-fit: contain; }
        </style>
        </head>
        <body><img src="\(url.absoluteString)" /></body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
