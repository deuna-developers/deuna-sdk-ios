//
//  Constants.swift
//
//
//  Created by deuna on 4/7/24.
//

import Foundation

public enum ErrorCodes {
    static let initializationFailed = "INITIALIZATION_ERROR"
    static let unknown = "UNKNOWN_ERROR"
}

public enum ErrorMessages {
    static let unknown = "Unknown error"
}

public enum LoadUrlErrorMessages {
    static let c1001 = "Network timeout error."
    static let c1002 = "The URL cannot be found."
    static let c1003 = "The server cannot be found."
    static let c1004 = "Internet connection was lost."
    static let c1005 = "The server's security certificate is invalid."
    static let unknown = "Unknown error while loading the URL."

    public static func getMessage(code: Int) -> String {
        let errorMessages: [Int: String] = [
            -1001: LoadUrlErrorMessages.c1001,
            -1002: LoadUrlErrorMessages.c1002,
            -1003: LoadUrlErrorMessages.c1003,
            -1004: LoadUrlErrorMessages.c1004,
            -1005: LoadUrlErrorMessages.c1005
        ]
        return errorMessages[code] ?? LoadUrlErrorMessages.unknown
    }
}

public enum PaymentsErrorMessages {
    static let orderTokenMustNotBeEmpty = "OrderToken must not be empty."
    static let paymentLinkCouldNotBeGenerated = "Payment link could not be generated."
    static let noInternetConnection = "No internet connection available."
    static let orderCouldNotBeRetrieved = "Order could not be retrieved."
}

public enum ElementsErrorMessages {
    static let paymentLinkCouldNotBeGenerated = "Vault link could not be generated."
    static let invalidUserInfo = "Invalid instance of UserInfo: check the firstName, lastName and email fields."
    static let missingUserTokenOrUserInfo = "userToken or userInfo must be passed."
}

public enum PaymentWidgetErrors {
    /// Use this error when an invalid token was used to show the checkout widget or the payment widget
    static let invalidOrderToken = PaymentsError(
        type: .invalidOrderToken,
        metadata: PaymentsError.ErrorMetadata(
            code: ErrorCodes.initializationFailed,
            message: PaymentsErrorMessages.orderTokenMustNotBeEmpty
        )
    )

    /// Use this error when the payment link could not be generated
    static let linkCouldNotBeGenerated = PaymentsError(
        type: .initializationFailed,
        metadata: PaymentsError.ErrorMetadata(
            code: ErrorCodes.initializationFailed,
            message: PaymentsErrorMessages.paymentLinkCouldNotBeGenerated
        )
    )

    /// Use this error when the checkout widget or payment widget could not be launched due to internet issues
    static let noInternetConnection = PaymentsError(
        type: .noInternetConnection
    )

    /// Use this error when the order could not be retrieved before show the checkout widget
    static let orderCouldNotBeRetrieved = PaymentsError(
        type: .orderCouldNotBeRetrieved,
        metadata: PaymentsError.ErrorMetadata(
            code: ErrorCodes.initializationFailed,
            message: PaymentsErrorMessages.paymentLinkCouldNotBeGenerated
        )
    )
}

public enum ElementsVaultWidgetErrors {
    /// Use this error when the vault link could not be generated
    static let linkCouldNotBeGenerated = ElementsError(
        type: .initializationFailed,
        metadata: ElementsError.ErrorMetadata(
            code: ErrorCodes.initializationFailed,
            message: ElementsErrorMessages.paymentLinkCouldNotBeGenerated
        )
    )

    static let invalidUserInfo = ElementsError(
        type: .initializationFailed,
        metadata: ElementsError.ErrorMetadata(
            code: ErrorCodes.initializationFailed,
            message: ElementsErrorMessages.invalidUserInfo
        )
    )

    static let missingUserTokenOrUserInfo = ElementsError(
        type: .initializationFailed,
        metadata: ElementsError.ErrorMetadata(
            code: ErrorCodes.initializationFailed,
            message: ElementsErrorMessages.missingUserTokenOrUserInfo
        )
    )

    /// Use this error when the vault widget could not be launched due to internet issues
    static let noInternetConnection = ElementsError(
        type: .noInternetConnection
    )
}

public enum ElementsTypeKey {
    public static let name = "name"
}

public enum ElementsWidget {
    public static let vault = "vault"
    public static let clickToPay = "click_to_pay"
}

public enum WebViewUserContentControllerNames {
    public static let refetchOrder = "refetchOrder"
    public static let consoleLog = "consoleLog"
    public static let xprops = "xprops"
    public static let deuna = "deuna"
    public static let saveBase64Image = "saveBase64Image"
    public static let closeWindow = "closeWindow"
}

public enum QueryParameters {
    static let mode = "mode"
    static let widget = "widget"
    static let userToken = "userToken"
    static let cssFile = "cssFile"
    static let styleFile = "styleFile"
    static let xpropsB64 = "xpropsB64"
    static let paymentMethods = "paymentMethods"
    static let checkoutModules = "checkoutModules"
    static let publicApiKey = "publicApiKey"
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let email = "email"
    static let language = "language"
}

public enum OnEmbedEvents {
    static let apmClosed = "apmClosed"
}
