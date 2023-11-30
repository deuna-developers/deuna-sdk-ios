import WebKit
import UIKit
import AnyCodable


public protocol CheckoutEventHandler: AnyObject {
    func onPurchase(data: Any?)
    func onPurchaseError(errorMessage: String, errorCode: String)
    func onLinkClose(webView: WKWebView)
}
