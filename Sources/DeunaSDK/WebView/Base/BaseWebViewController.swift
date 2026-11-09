import UIKit
@preconcurrency import WebKit



class BaseWebViewController: UIViewController {
    
    let controller: WebViewController
   
    
    init(openRequestNavigationsInNewTab: Bool) {
        controller = WebViewController(
            openRequestNavigationsInNewTab: openRequestNavigationsInNewTab
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

