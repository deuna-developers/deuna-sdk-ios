//
//  DeunaWidget.swift
//  DeunaSDK
//
//  Created by deuna on 27/3/25.
//

import SwiftUICore
import SwiftUI

public class DeunaWidgetConfiguration: NSObject {}

public class PaymentWidgetConfiguration: DeunaWidgetConfiguration {
    let orderToken: String
    let callbacks: PaymentWidgetCallbacks
    let userToken: String?
    let styleFile: String?
    let paymentMethods: [Json]
    let checkoutModules: [Json]
    let language: String?
    let hidePayButton: Bool?
    let behavior: Json?

    public init(
        orderToken: String,
        callbacks: PaymentWidgetCallbacks,
        userToken: String? = nil,
        styleFile: String? = nil,
        paymentMethods: [Json] = [],
        checkoutModules: [Json] = [],
        language: String? = nil,
        hidePayButton: Bool? = false,
        behavior: Json? = nil
    ) {
        self.orderToken = orderToken
        self.callbacks = callbacks
        self.userToken = userToken
        self.styleFile = styleFile
        self.paymentMethods = paymentMethods
        self.checkoutModules = checkoutModules
        self.language = language
        self.hidePayButton = hidePayButton
        self.behavior = behavior
    }
}

public class NextActionWidgetConfiguration: DeunaWidgetConfiguration {
    let orderToken: String
    let callbacks: NextActionCallbacks
    let language: String?

    public init(
        orderToken: String,
        callbacks: NextActionCallbacks,
        language: String? = nil
    ) {
        self.orderToken = orderToken
        self.callbacks = callbacks
        self.language = language
    }
}

public class VoucherWidgetConfiguration: DeunaWidgetConfiguration {
    let orderToken: String
    let callbacks: VoucherCallbacks
    let language: String?

    public init(
        orderToken: String,
        callbacks: VoucherCallbacks,
        language: String? = nil
    ) {
        self.orderToken = orderToken
        self.callbacks = callbacks
        self.language = language
    }
}

public class CheckoutWidgetConfiguration: DeunaWidgetConfiguration {
    let orderToken: String
    let callbacks: CheckoutCallbacks
    let userToken: String?
    let styleFile: String?
    let language: String?
    let hidePayButton: Bool?
    let closeEvents: Set<CheckoutEvent>

    public init(
        orderToken: String,
        callbacks: CheckoutCallbacks,
        closeEvents: Set<CheckoutEvent> = [],
        userToken: String? = nil,
        styleFile: String? = nil,
        language: String? = nil,
        hidePayButton: Bool? = false
    ) {
        self.orderToken = orderToken
        self.callbacks = callbacks
        self.userToken = userToken
        self.styleFile = styleFile
        self.language = language
        self.hidePayButton = hidePayButton
        self.closeEvents = closeEvents
    }
}

public class ElementsWidgetConfiguration: DeunaWidgetConfiguration {
    let userToken: String?
    let callbacks: ElementsCallbacks
    let closeEvents: Set<ElementsEvent>
    let userInfo: DeunaSDK.UserInfo?
    let styleFile: String?
    let types: [Json]
    let language: String?
    let orderToken: String?
    let widgetExperience: ElementsWidgetExperience?
    let hidePayButton: Bool?
    let behavior: Json?

    public init(
        userToken: String? = nil,
        callbacks: ElementsCallbacks,
        closeEvents: Set<ElementsEvent> = [],
        userInfo: DeunaSDK.UserInfo? = nil,
        styleFile: String? = nil,
        types: [Json] = [],
        language: String? = nil,
        orderToken: String? = nil,
        widgetExperience: ElementsWidgetExperience? = nil,
        hidePayButton: Bool? = false,
        behavior: Json? = nil
    ) {
        self.userToken = userToken
        self.callbacks = callbacks
        self.closeEvents = closeEvents
        self.userInfo = userInfo
        self.styleFile = styleFile
        self.types = types
        self.language = language
        self.orderToken = orderToken
        self.widgetExperience = widgetExperience
        self.hidePayButton = hidePayButton
        self.behavior = behavior
    }
}

@available(iOS 14.0, *)
public struct DeunaWidget: View {
    public let deunaSDK: DeunaSDK
    public let configuration: DeunaWidgetConfiguration
    
    public init(deunaSDK: DeunaSDK, configuration: DeunaWidgetConfiguration) {
        self.deunaSDK = deunaSDK
        self.configuration = configuration
    }

    @State private var widgetView: AnyView?

    public var body: some View {
        Group {
            if let widgetView = widgetView {
                widgetView.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.onAppear {
            /// validar configuracion
            switch configuration {
            case let config as PaymentWidgetConfiguration:
                let view = self.deunaSDK.paymentWidget(configuration: config)
                widgetView = AnyView(view)

            case let config as CheckoutWidgetConfiguration:
                let view = self.deunaSDK.checkoutWidget(configuration: config)
                widgetView = AnyView(view)

            case let config as ElementsWidgetConfiguration:
                let view = self.deunaSDK.elementsWidget(configuration: config)
                widgetView = AnyView(view)
                
            case let config as NextActionWidgetConfiguration:
                let view = self.deunaSDK.nextActionWidget(configuration: config)
                widgetView = AnyView(view)
                
            case let config as VoucherWidgetConfiguration:
                let view = self.deunaSDK.voucherWidget(configuration: config)
                widgetView = AnyView(view)

            default:
                print("❌ DeunaWidget error: unknown configuration type \(type(of: configuration))")
            }
        }
    }
}
