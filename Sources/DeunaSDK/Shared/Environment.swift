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

    var config: EnvConfig {
        switch self {
        case .development:
            return EnvConfig(
                checkoutBaseUrl: "https://api.dev.deuna.io",
                elementsBaseUrl: "https://elements.dev.deuna.io",
                clientApiBaseUrl: "https://api.dev.deuna.io:443",
                paymentWidgetBaseUrl: "https://pay.dev.deuna.io",
                fingerprintKey: "sB9jPdnpvLP3FkjjUPi3"
            )
        case .production:
            return EnvConfig(
                checkoutBaseUrl: "https://api.deuna.io",
                elementsBaseUrl: "https://elements.deuna.com",
                clientApiBaseUrl: "https://apigw.getduna.com:443",
                paymentWidgetBaseUrl: "https://pay.deuna.io",
                fingerprintKey: "PczoxhUz1RUyPv5Ih7nM"
            )
        case .staging:
            return EnvConfig(
                checkoutBaseUrl: "https://api.stg.deuna.io",
                elementsBaseUrl: "https://elements.stg.deuna.io",
                clientApiBaseUrl: "https://staging-apigw.getduna.com:443",
                paymentWidgetBaseUrl: "https://pay.stg.deuna.com",
                fingerprintKey: "sB9jPdnpvLP3FkjjUPi3"
            )
        case .sandbox:
            return EnvConfig(
                checkoutBaseUrl: "https://api.sandbox.deuna.io",
                elementsBaseUrl: "https://elements.sandbox.deuna.io",
                clientApiBaseUrl: "https://api.sandbox.deuna.io",
                paymentWidgetBaseUrl: "https://pay.sandbox.deuna.io",
                fingerprintKey: "sB9jPdnpvLP3FkjjUPi3"
            )
        }
    }
    
    var name: String {
        switch self {
        case .development:
            return "develop"
        case .production:
            return "production"
        case .staging:
            return "staging"
        case .sandbox:
            return "sandbox"
        }
    }
}

struct EnvConfig {
    let checkoutBaseUrl: String
    let elementsBaseUrl: String
    let clientApiBaseUrl: String
    let paymentWidgetBaseUrl: String
    let fingerprintKey: String

    init(
        checkoutBaseUrl: String,
        elementsBaseUrl: String,
        clientApiBaseUrl:String,
        paymentWidgetBaseUrl: String,
        fingerprintKey: String
    ) {
        self.checkoutBaseUrl = checkoutBaseUrl
        self.elementsBaseUrl = elementsBaseUrl
        self.clientApiBaseUrl = clientApiBaseUrl
        self.paymentWidgetBaseUrl = paymentWidgetBaseUrl
        self.fingerprintKey = fingerprintKey
    }
}
