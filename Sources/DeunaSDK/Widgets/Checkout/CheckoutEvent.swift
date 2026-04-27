//
//  CheckoutEvent.swift
//
//
//  Created by Darwin on 29/2/24.
//

import Foundation

public enum CheckoutEvent: String, Codable {
    case adBlock
    case apmCancelPayment
    case apmCancelPaymentConfirm
    case apmClickRedirect
    case apmConsentResponse
    case apmCopyId
    case apmDocIdInitiated
    case apmGoToThankyouPage
    case apmOtpAccepted
    case apmOtpRejected
    case apmPhoneInitiated
    case apmReadInstructions
    case apmReferenceShown
    case apmSaveId
    case apmSuccess
    case apmSuccessful
    case appCrash
    case backTo
    case benefitsStarted
    case billingChange
    case billingFormSave
    case billingSet
    case billingStarted
    case changeAddress
    case changeCart
    case checkoutFailed
    case checkoutStarted
    case couponFailed
    case couponRemoveFailed
    case custom
    case donationsStarted
    case donationsUsed
    case goTo
    case guest
    case linkClose
    case linkFailed
    case linkStarted
    case login
    case loginEmailEntered
    case loginEmailInitiated
    case loginEmailTooltip
    case loginOtpAccepted
    case loginOtpContinueAsGuest
    case loginOtpStarted
    case loginStarted
    case loginWithCrossDomain
    case onBinDetected
    case onInstallmentSelected
    case paymentClick
    case paymentMethods3dsInitiated
    case paymentMethodsAddCard
    case paymentMethodsCardExpirationDateEntered
    case paymentMethodsCardExpirationDateInitiated
    case paymentMethodsCardMsiInitiated
    case paymentMethodsCardNameEntered
    case paymentMethodsCardNameInitiated
    case paymentMethodsCardNumberEntered
    case paymentMethodsCardNumberInitiated
    case paymentMethodsCardSecurityCodeEntered
    case paymentMethodsCardSecurityCodeInitiated
    case paymentMethodsEntered
    case paymentMethodsNotAvailable
    case paymentMethodsSelected
    case paymentMethodsShowMore
    case paymentMethodsShowMyCards
    case paymentMethodsStarted
    case paymentProcessing
    case pointsToWinStarted
    case purchase
    case purchaseError
    case purchaseRejected
    case shippingAddressSearchEntered
    case shippingAddressStarted
    case shippingMethodsActualLocation
    case shippingMethodsStarted
    case userInfoDataNotSaved
    case userInfoDataSaved
    case userInfoFirstNameEntered
    case userInfoLastNameEntered
    case userInfoPhoneEntered
    case userInfoPhoneTooltip
    case userInfoStarted
    case userInfoUpdateClick
}
