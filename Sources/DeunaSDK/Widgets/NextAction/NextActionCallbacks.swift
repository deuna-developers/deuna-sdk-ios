//
//  NextActionCallbacks.swift
//  DeunaSDK
//
//  Created by deuna on 4/4/25.
//

public class NextActionCallbacks: BaseCallbacks<CheckoutEvent, PaymentsError> {
    public override init(
        onSuccess: OnSuccess? = nil,
        onError: OnError<PaymentsError>? = nil,
        onClosed: OnClosed? = nil,
        onEventDispatch: OnEventDispatch<CheckoutEvent>? = nil
    ) {
        super.init(
            onSuccess: onSuccess,
            onError: onError,
            onClosed: onClosed,
            onEventDispatch: onEventDispatch
        )
    }
}
