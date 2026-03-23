//
//  ElementsEvent.swift
//
//
//  Created on 6/3/24.
//

import Foundation

public enum ElementsEvent: String, Codable {
    case adBlock
    case appCrash
    case backTo
    case billingChange
    case billingFormSave
    case billingSet
    case billingStarted
    case cardCreationError
    case cardSuccessfullyCreated
    case changeAddress
    case changeCart
    case checkoutFailed
    case checkoutStarted
    case goTo
    case guest
    case onInstallmentSelected
    case paymentMethodsCardExpirationDateEntered
    case paymentMethodsCardExpirationDateInitiated
    case paymentMethodsCardIdentityNumberEntered
    case paymentMethodsCardIdentityNumberInitiated
    case paymentMethodsCardMsiInitiated
    case paymentMethodsCardNameEntered
    case paymentMethodsCardNameInitiated
    case paymentMethodsCardNumberEntered
    case paymentMethodsCardNumberInitiated
    case paymentMethodsCardSecurityCodeEntered
    case paymentMethodsCardSecurityCodeInitiated
    case paymentMethodsChangeAmountEntered
    case paymentMethodsChangeAmountInitiated
    case paymentMethodsChangeCard
    case paymentMethodSplitPayments
    case vaultClickRedirect3DS
    case vaultClosed
    case vaultFailed
    case vaultProcessing
    case vaultSaveClick
    case vaultSaveError
    case vaultSaveSuccess
    case vaultStarted
}
