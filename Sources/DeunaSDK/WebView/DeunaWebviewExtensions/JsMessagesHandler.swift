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
    
    /// Handle post messages
    func allowPostMessageHandler(
        didReceive message: WKScriptMessage
    ) -> Bool {
        guard let messageBody = message.body as? String else {
            return false
        }
        
        switch message.name {
        case WebViewUserContentControllerNames.consoleLog:
            DeunaLogs.info("console.log: \(messageBody)")
            return false
        default:
            return true
        }
    }

}
