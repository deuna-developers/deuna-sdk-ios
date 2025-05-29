//
//  JsMessageshandler.swift
//  DeunaSDK
//
//  Created by DEUNA on 21/10/24.
//

import WebKit

extension DeunaWebViewController {
    /// Handler for receiving JavaScript messages.
    ///
    /// - Parameters:
    ///   - userContentController: The user content controller.
    ///   - message: The message received.
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {}

}
