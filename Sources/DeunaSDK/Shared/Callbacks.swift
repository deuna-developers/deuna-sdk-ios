//
//  Callbacks.swift
//
//
//  Created by Darwin on 6/3/24.
//

import Foundation

public typealias OnSuccess<S, E> = (S) -> Void
public typealias EventListener<S, E> = (E, S) -> Void
public typealias OnError<Error> = (Error) -> Void
public typealias VoidCallback = () -> Void

public protocol BaseCallbacksProtocol{
    associatedtype SuccessData
    associatedtype EventData
    associatedtype Error

    var onSuccess: OnSuccess<SuccessData, EventData>? { get }
      var onError: OnError<Error>? { get }
      var onClosed: VoidCallback? { get }
      var onCanceled: VoidCallback? { get }
      var eventListener: EventListener<SuccessData, EventData>? { get }
}

public class BaseCallbacks<SuccessData, EventData, Error>: NSObject {
    public let onSuccess: OnSuccess<SuccessData, EventData>?
    public let onError: OnError<Error>?
    public let onClosed: VoidCallback?
    public let onCanceled: VoidCallback?
    public let eventListener: EventListener<SuccessData, EventData>?

    public init(onSuccess: OnSuccess<SuccessData, EventData>?, onError: OnError<Error>?, onClosed: VoidCallback?, onCanceled: VoidCallback?, eventListener: EventListener<SuccessData, EventData>?) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onClosed = onClosed
        self.onCanceled = onCanceled
        self.eventListener = eventListener
    }
}
// Implement the BaseCallbacksProtocol for BaseCallbacks
extension BaseCallbacks: BaseCallbacksProtocol {
}

public class CheckoutCallbacks: BaseCallbacks<CheckoutResponse, CheckoutEvent, CheckoutError> {}

public class ElementsCallbacks: BaseCallbacks<ElementsResponse, ElementsEvent, ElementsError> {}
