import DeunaSDK
import Foundation

/// Builds widget callback sets and routes results to app events/screens.
struct WidgetCallbacksFactory {
    let onPaymentSuccess: ([String: Any]) -> Void
    let onSaveCardSuccess: ([String: Any]) -> Void
    let onPaymentMethodsEntered: () -> Void

    func payment() -> PaymentWidgetCallbacks {
        PaymentWidgetCallbacks(
            onSuccess: { data in
                onPaymentSuccess(data)
            },
            onError: { print($0) },
            onClosed: { print("Widget closed: \($0)") },
            onEventDispatch: { event, _ in
                if event == .paymentMethodsEntered {
                    onPaymentMethodsEntered()
                }
            }
        )
    }

    func checkout() -> CheckoutCallbacks {
        CheckoutCallbacks(
            onSuccess: { data in
                onPaymentSuccess(data)
            },
            onError: { print($0) },
            onClosed: { print("Widget closed: \($0)") },
            onEventDispatch: nil
        )
    }

    func elements() -> ElementsCallbacks {
        ElementsCallbacks(
            onSuccess: { data in
                onSaveCardSuccess(data)
            },
            onError: { print($0) },
            onClosed: { print("Widget closed: \($0)") },
            onEventDispatch: nil
        )
    }

    func nextAction() -> NextActionCallbacks {
        NextActionCallbacks(
            onSuccess: { data in
                onPaymentSuccess(data)
            },
            onError: { print($0) }
        )
    }

    func voucher() -> VoucherCallbacks {
        VoucherCallbacks(
            onSuccess: { data in
                onPaymentSuccess(data)
            },
            onError: { print($0) }
        )
    }
}
