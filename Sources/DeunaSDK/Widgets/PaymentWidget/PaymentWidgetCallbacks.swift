//
//  PaymentWidgetCallbacks.swift
//  DeunaSDK
//
//  Created by deuna on 4/4/25.
//

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
