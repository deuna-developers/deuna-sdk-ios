//
//  Callbacks.swift
//
//
//  Created by DEUNA on 6/3/24.
//

import Foundation

public typealias OnSuccess = (Json) -> Void
public typealias OnEventDispatch<E> = (E, Json) -> Void
public typealias OnError<Error> = (Error) -> Void
public typealias VoidCallback = () -> Void
public typealias OnClosed = (CloseAction) -> Void
public typealias OnPayload = (Json?) -> Void

public protocol BaseCallbacksProtocol {
    associatedtype EventData
    associatedtype Error

    var onSuccess: OnSuccess? { get }
    var onError: OnError<Error>? { get }
    var onClosed: OnClosed? { get }
    var onEventDispatch: OnEventDispatch<EventData>? { get }
}

// Implement the BaseCallbacksProtocol for BaseCallbacks
extension BaseCallbacks: BaseCallbacksProtocol {}

public class BaseCallbacks<EventData, Error>: NSObject {
    public let onSuccess: OnSuccess?
    public let onError: OnError<Error>?
    public let onClosed: OnClosed?
    public let onEventDispatch: OnEventDispatch<EventData>?

    @available(
        *, deprecated,
        message: "Use init(onSuccess: ..,onError: ...,onEventDispatch: ...) instead",
        renamed: "init(onSuccess:onError:onCanceled:onEventDispatch:)"
    )
    public init(
        onSuccess: OnSuccess?,
        onError: OnError<Error>?,
        onClosed: OnClosed?,
        eventListener: OnEventDispatch<EventData>?
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onClosed = onClosed
        self.onEventDispatch = eventListener
    }

    public init(
        onSuccess: OnSuccess?,
        onError: OnError<Error>?,
        onClosed: OnClosed?,
        onEventDispatch: OnEventDispatch<EventData>?
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onClosed = onClosed
        self.onEventDispatch = onEventDispatch
    }
}

public class CheckoutCallbacks: BaseCallbacks<CheckoutEvent, PaymentsError> {}

public class ElementsCallbacks: BaseCallbacks<ElementsEvent, ElementsError> {}

public class PaymentWidgetCallbacks: BaseCallbacks<CheckoutEvent, PaymentsError> {
    public let onCardBinDetected: OnPayload?
    public let onInstallmentSelected: OnPayload?
    public let onPaymentProcessing: VoidCallback?

    public init(
        onSuccess: OnSuccess? = nil,
        onError: OnError<PaymentsError>? = nil,
        onClosed: OnClosed? = nil,
        onCardBinDetected: OnPayload? = nil,
        onInstallmentSelected: OnPayload? = nil,
        onPaymentProcessing: VoidCallback? = nil,
        onEventDispatch: OnEventDispatch<CheckoutEvent>? = nil
    ) {
        self.onCardBinDetected = onCardBinDetected
        self.onInstallmentSelected = onInstallmentSelected
        self.onPaymentProcessing = onPaymentProcessing

        super.init(
            onSuccess: onSuccess,
            onError: onError,
            onClosed: onClosed,
            onEventDispatch: onEventDispatch
        )
    }
}
