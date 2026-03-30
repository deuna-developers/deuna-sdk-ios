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
    var onCardBinDetected: OnPayload? { get }
    var onInstallmentSelected: OnPayload? { get }
    var onEventDispatch: OnEventDispatch<EventData>? { get }
}

// Implement the BaseCallbacksProtocol for BaseCallbacks
extension BaseCallbacks: BaseCallbacksProtocol {}

public class BaseCallbacks<EventData, Error>: NSObject {
    public let onSuccess: OnSuccess?
    public let onError: OnError<Error>?
    public let onClosed: OnClosed?
    public let onCardBinDetected: OnPayload?
    public let onInstallmentSelected: OnPayload?
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
        self.onCardBinDetected = nil
        self.onInstallmentSelected = nil
        self.onEventDispatch = eventListener
    }

    @available(
        *, deprecated,
        message: "Use init(onSuccess: .., onError: ..., onClosed: ..., onCardBinDetected: ..., onInstallmentSelected: ..., onEventDispatch: ...) instead",
        renamed: "init(onSuccess:onError:onClosed:onCardBinDetected:onInstallmentSelected:onEventDispatch:)"
    )
    public init(
        onSuccess: OnSuccess?,
        onError: OnError<Error>?,
        onClosed: OnClosed?,
        onCardBinDetected: OnPayload?,
        onInstallmentSelected: OnPayload?,
        eventListener: OnEventDispatch<EventData>?
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onClosed = onClosed
        self.onCardBinDetected = onCardBinDetected
        self.onInstallmentSelected = onInstallmentSelected
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
        self.onCardBinDetected = nil
        self.onInstallmentSelected = nil
        self.onEventDispatch = onEventDispatch
    }

    public init(
        onSuccess: OnSuccess?,
        onError: OnError<Error>?,
        onClosed: OnClosed?,
        onCardBinDetected: OnPayload?,
        onInstallmentSelected: OnPayload?,
        onEventDispatch: OnEventDispatch<EventData>?
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onClosed = onClosed
        self.onCardBinDetected = onCardBinDetected
        self.onInstallmentSelected = onInstallmentSelected
        self.onEventDispatch = onEventDispatch
    }
}
