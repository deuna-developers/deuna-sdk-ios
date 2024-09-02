//
//  Callbacks.swift
//
//
//  Created by Darwin on 6/3/24.
//

import Foundation

public typealias OnSuccess<S, E> = (S) -> Void
public typealias OnEventDispatch<S, E> = (E, S) -> Void
public typealias OnError<Error> = (Error) -> Void
public typealias VoidCallback = () -> Void

public protocol BaseCallbacksProtocol {
    associatedtype SuccessData
    associatedtype EventData
    associatedtype Error

    var onSuccess: OnSuccess<SuccessData, EventData>? { get }
    var onError: OnError<Error>? { get }
    var onClosed: VoidCallback? { get }
    var onCanceled: VoidCallback? { get }
    var onEventDispatch: OnEventDispatch<SuccessData, EventData>? { get }
}

public class BaseCallbacks<SuccessData, EventData, Error>: NSObject {
    public let onSuccess: OnSuccess<SuccessData, EventData>?
    public let onError: OnError<Error>?
    public let onClosed: VoidCallback?
    public let onCanceled: VoidCallback?
    public let onEventDispatch: OnEventDispatch<SuccessData, EventData>?

    @available(
        *, deprecated,
        message: "Use init(onSuccess: ..,onError: ..., onCanceled: ... ,onEventDispatch: ...) instead",
        renamed: "init(onSuccess:onError:onCanceled:onEventDispatch:)"
    )
    public init(
        onSuccess: OnSuccess<SuccessData, EventData>?,
        onError: OnError<Error>?, onClosed: VoidCallback?,
        onCanceled: VoidCallback?,
        eventListener: OnEventDispatch<SuccessData, EventData>?
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onClosed = onClosed
        self.onCanceled = onCanceled
        self.onEventDispatch = eventListener
    }

    public init(
        onSuccess: OnSuccess<SuccessData, EventData>?,
        onError: OnError<Error>?, onClosed: VoidCallback?,
        onCanceled: VoidCallback?,
        onEventDispatch: OnEventDispatch<SuccessData, EventData>?
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onClosed = onClosed
        self.onCanceled = onCanceled
        self.onEventDispatch = onEventDispatch
    }
}

// Implement the BaseCallbacksProtocol for BaseCallbacks
extension BaseCallbacks: BaseCallbacksProtocol {}

public class CheckoutCallbacks: BaseCallbacks<Json, CheckoutEvent, PaymentsError> {}

public class ElementsCallbacks: BaseCallbacks<Json, ElementsEvent, ElementsError> {}
