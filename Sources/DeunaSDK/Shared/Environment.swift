//
//  DeunaSDK+Environment.swift
//

import Foundation
import UIKit


/// Enum to represent the possible environments of the SDK.
@objc public enum Environment :Int {
    case development
    case production
    case staging
    case sandbox

    var baseUrls: BaseUrls {
        switch self {
        case .development:
            return BaseUrls(
                checkoutBaseUrl: "https://api.dev.deuna.io",
                elementsBaseUrl: "https://elements.dev.deuna.io",
                clientApiBaseUrl: "https://api.dev.deuna.io:443",
                paymentWidgetBaseUrl: "https://pay.dev.deuna.io"
            )
        case .production:
            return BaseUrls(
                checkoutBaseUrl: "https://api.deuna.io",
                elementsBaseUrl: "https://elements.deuna.com",
                clientApiBaseUrl: "https://apigw.getduna.com:443",
                paymentWidgetBaseUrl: "https://pay.deuna.io"
            )
        case .staging:
            return BaseUrls(
                checkoutBaseUrl: "https://api.stg.deuna.io",
                elementsBaseUrl: "https://elements.stg.deuna.io",
                clientApiBaseUrl: "https://staging-apigw.getduna.com:443",
                paymentWidgetBaseUrl: "https://pay.stg.deuna.com"
            )
        case .sandbox:
            return BaseUrls(
                checkoutBaseUrl: "https://api.sandbox.deuna.io",
                elementsBaseUrl: "https://elements.sandbox.deuna.io",
                clientApiBaseUrl: "https://api.sandbox.deuna.io",
                paymentWidgetBaseUrl: "https://pay.sandbox.deuna.io"
            )
        }
    }
}

struct BaseUrls {
    let checkoutBaseUrl: String
    let elementsBaseUrl: String
    let clientApiBaseUrl: String
    let paymentWidgetBaseUrl: String

    init(
        checkoutBaseUrl: String,
        elementsBaseUrl: String,
        clientApiBaseUrl:String,
        paymentWidgetBaseUrl: String
    ) {
        self.checkoutBaseUrl = checkoutBaseUrl
        self.elementsBaseUrl = elementsBaseUrl
        self.clientApiBaseUrl = clientApiBaseUrl
        self.paymentWidgetBaseUrl = paymentWidgetBaseUrl
    }
}
