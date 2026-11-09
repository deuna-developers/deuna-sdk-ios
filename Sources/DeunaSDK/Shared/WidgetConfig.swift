//
//  WidgetConfig.swift
//  DeunaSDK
//
//  Created by Darwin on 28/5/25.
//

class WidgetConfig {
    let orderToken: String
    let userToken: String?
    let behavior: Json?

    init(
        orderToken: String,
        userToken: String?,
        behavior: Json?
    ) {
        self.orderToken = orderToken
        self.userToken = userToken
        self.behavior = behavior
    }
}
