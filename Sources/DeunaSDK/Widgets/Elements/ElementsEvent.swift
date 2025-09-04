//
//  ElementsEvent.swift
//
//
//  Created on 6/3/24.
//

import Foundation

public enum ElementsEvent: String, Codable {
    case vaultClosed
    case vaultProcessing
    case vaultSaveClick
    case vaultStarted
    case vaultFailed
    case cardSuccessfullyCreated
    case changeAddress
    case changeCart
    case vaultSaveError
    case vaultSaveSuccess
    case vaultClickRedirect3DS
    case cardCreationError
    case paymentMethodsCardIdentityNumberInitiated
    case paymentMethodsCardIdentityNumberEntered
    case paymentMethodsCardNameInitiated
    case paymentMethodsCardNameEntered
    case paymentMethodsCardSecurityCodeInitiated
    case paymentMethodsCardSecurityCodeEntered
    case paymentMethodsCardExpirationDateEntered
    case paymentMethodsCardExpirationDateInitiated
    case paymentMethodsCardNumberEntered
    case paymentMethodsCardNumberInitiated
}
