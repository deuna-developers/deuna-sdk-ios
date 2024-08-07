import Foundation

public typealias PaymentWidgetOnReFetchOrder = (@escaping (Json?) -> Void) -> Void
public typealias PaymentWidgeOnSuccess = (Json) -> Void
public typealias PaymentWidgeOnError = (PaymentsError) -> Void
public typealias PaymentWidgeOnVoidCallback = () -> Void
public typealias PaymentWidgetOnCardBinDetected = (Json?, @escaping PaymentWidgetOnReFetchOrder) -> Void
public typealias PaymentWidgetOnInstallmentSelected = (Json?, @escaping PaymentWidgetOnReFetchOrder) -> Void

/// Class defining the different callbacks that can be invoked by the payment widget
public class PaymentWidgetCallbacks: NSObject {
    public let onSuccess: PaymentWidgeOnSuccess?
    public let onError: PaymentWidgeOnError?
    public let onClosed: PaymentWidgeOnVoidCallback?
    public let onCanceled: PaymentWidgeOnVoidCallback?
    public let onCardBinDetected: PaymentWidgetOnCardBinDetected?
    public let onInstallmentSelected: PaymentWidgetOnInstallmentSelected?

    public init(
        onSuccess: PaymentWidgeOnSuccess?,
        onError: PaymentWidgeOnError?,
        onClosed: PaymentWidgeOnVoidCallback?,
        onCanceled: PaymentWidgeOnVoidCallback?,
        onCardBinDetected: PaymentWidgetOnCardBinDetected?,
        onInstallmentSelected: PaymentWidgetOnInstallmentSelected?
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onClosed = onClosed
        self.onCanceled = onCanceled
        self.onCardBinDetected = onCardBinDetected
        self.onInstallmentSelected = onInstallmentSelected
    }
}
