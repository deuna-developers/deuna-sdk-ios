//
//  DeunaWidget.swift
//  DeunaSDK
//
//  Created by deuna on 27/3/25.
//

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
    let fraudCredentials: Json?
    let customUserAgent: String?
    let domain: String?

    public init(
        orderToken: String,
        callbacks: PaymentWidgetCallbacks,
        userToken: String? = nil,
        styleFile: String? = nil,
        paymentMethods: [Json] = [],
        checkoutModules: [Json] = [],
        language: String? = nil,
        hidePayButton: Bool? = false,
        behavior: Json? = nil,
        fraudCredentials: Json? = nil,
        customUserAgent: String? = nil,
        domain: String? = nil
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
        self.fraudCredentials = fraudCredentials
        self.customUserAgent = customUserAgent
        self.domain = domain
    }
}

public class NextActionWidgetConfiguration: DeunaWidgetConfiguration {
    let orderToken: String
    let callbacks: NextActionCallbacks
    let language: String?
    let fraudCredentials: Json?
    let customUserAgent: String?
    let domain: String?

    public init(
        orderToken: String,
        callbacks: NextActionCallbacks,
        language: String? = nil,
        fraudCredentials: Json? = nil,
        customUserAgent: String? = nil,
        domain: String? = nil
    ) {
        self.orderToken = orderToken
        self.callbacks = callbacks
        self.language = language
        self.fraudCredentials = fraudCredentials
        self.customUserAgent = customUserAgent
        self.domain = domain
    }
}

public class VoucherWidgetConfiguration: DeunaWidgetConfiguration {
    let orderToken: String
    let callbacks: VoucherCallbacks
    let language: String?
    let fraudCredentials: Json?
    let customUserAgent: String?
    let domain: String?

    public init(
        orderToken: String,
        callbacks: VoucherCallbacks,
        language: String? = nil,
        fraudCredentials: Json? = nil,
        customUserAgent: String? = nil,
        domain: String? = nil
    ) {
        self.orderToken = orderToken
        self.callbacks = callbacks
        self.language = language
        self.fraudCredentials = fraudCredentials
        self.customUserAgent = customUserAgent
        self.domain = domain
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
    let fraudCredentials: Json?
    let customUserAgent: String?
    let domain: String?

    public init(
        orderToken: String,
        callbacks: CheckoutCallbacks,
        closeEvents: Set<CheckoutEvent> = [],
        userToken: String? = nil,
        styleFile: String? = nil,
        language: String? = nil,
        hidePayButton: Bool? = false,
        fraudCredentials: Json? = nil,
        customUserAgent: String? = nil,
        domain: String? = nil
    ) {
        self.orderToken = orderToken
        self.callbacks = callbacks
        self.userToken = userToken
        self.styleFile = styleFile
        self.language = language
        self.hidePayButton = hidePayButton
        self.closeEvents = closeEvents
        self.fraudCredentials = fraudCredentials
        self.customUserAgent = customUserAgent
        self.domain = domain
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
    let fraudCredentials: Json?
    let customUserAgent: String?
    let domain: String?

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
        behavior: Json? = nil,
        fraudCredentials: Json? = nil,
        customUserAgent: String? = nil,
        domain: String? = nil
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
        self.fraudCredentials = fraudCredentials
        self.customUserAgent = customUserAgent
        self.domain = domain
    }
}

@available(iOS 14.0, *)
public struct DeunaWidget: View {
    public let deunaSDK: DeunaSDK
    public let configuration: DeunaWidgetConfiguration

    /// Optional binding for the widget's content height.
    /// Provide this when placing the widget inside a `ScrollView` so it resizes
    /// to match the WebView content both when growing and shrinking.
    /// Initialize the bound value with a sensible loading height (e.g. 300).
    private let heightBinding: Binding<CGFloat>?

    /// Default initializer — the widget expands to fill all available space.
    public init(deunaSDK: DeunaSDK, configuration: DeunaWidgetConfiguration) {
        self.deunaSDK = deunaSDK
        self.configuration = configuration
        self.heightBinding = nil
    }

    /// Initializer for use inside a `ScrollView`.
    /// The widget sizes itself to match the WebView content height and updates
    /// `height` automatically whenever the content grows or shrinks.
    ///
    /// Example:
    /// ```swift
    /// @State private var widgetHeight: CGFloat = 300
    ///
    /// ScrollView {
    ///     VStack(spacing: 0) {
    ///         Color.blue.frame(height: 400)
    ///         DeunaWidget(deunaSDK: sdk, configuration: config, height: $widgetHeight)
    ///         Color.green.frame(height: 200)
    ///     }
    /// }
    /// ```
    public init(deunaSDK: DeunaSDK, configuration: DeunaWidgetConfiguration, height: Binding<CGFloat>) {
        self.deunaSDK = deunaSDK
        self.configuration = configuration
        self.heightBinding = height
    }

    @State private var widgetView: AnyView?

    public var body: some View {
        ZStack {
            if let widgetView = widgetView {
                widgetView.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: heightBinding == nil ? .infinity : nil)
        .frame(height: heightBinding.map { max($0.wrappedValue, 1) })
        .onAppear {
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

            if let heightBinding = heightBinding {
                deunaSDK.deunaWebViewController?.onHeightChange = { newHeight in
                    heightBinding.wrappedValue = newHeight
                }
            }
        }
    }
}
