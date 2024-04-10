//
//  CheckoutEvent.swift
//
//
//  Created by Darwin on 29/2/24.
//

import Foundation

public enum CheckoutEvent: String, Codable {
    case custom
    case purchase
    case purchaseError
    case linkClose
    case linkFailed
    case purchaseRejected
    case paymentProcessing
    case paymentMethodsAddCard
    case paymentMethodsCardExpirationDateInitiated
    case paymentMethodsCardNameEntered
    case apmSuccess
    case apmSuccessful
    case changeAddress
    case changeCart
    case paymentClick
    case apmClickRedirect
    case paymentMethodsCardNumberInitiated
    case paymentMethodsCardNumberEntered
    case paymentMethodsEntered
    case checkoutStarted
    case linkStarted
    case paymentMethodsStarted
    case paymentMethodsSelected
    case adBlock
    case paymentMethods3dsInitiated
    case pointsToWinStarted
    case paymentMethodsCardSecurityCodeInitiated
    case paymentMethodsCardSecurityCodeEntered
    case paymentMethodsCardExpirationDateEntered
    case paymentMethodsCardNameInitiated
    case paymentMethodsNotAvailable
    case paymentMethodsShowMore
    case paymentMethodsShowMyCards
    case benefitsStarted
    case donationsStarted
    case donationsUsed
}
