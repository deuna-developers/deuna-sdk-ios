//
//  Responses.swift
//  basic-integration
//
//  Created by DEUNA on 2/9/24.
//

import Foundation
import DeunaSDK

struct Error: Identifiable, Equatable {
    var id: String { code + message }
    let code: String
    let message: String

    init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

enum PaymentWidgetResult {
    case canceled
    case success([String: Any])
    case error(PaymentsError)
}

enum CheckoutResult {
    case canceled
    case success([String: Any])
    case error(PaymentsError)
}

enum ElementsResult {
    case canceled
    case success([String: Any])
    case error(ElementsError)
}
