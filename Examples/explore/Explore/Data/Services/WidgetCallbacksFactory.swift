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
            onError: { print("[ExploreApp] PaymentWidget Error: \($0)") },
            onClosed: { print("[ExploreApp] PaymentWidget closed: \($0)") },
            onEventDispatch: { event, data in
                print("[ExploreApp] PaymentWidget Event: \(event), data: \(data)")
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
            onError: { print("[ExploreApp] CheckoutWidget Error: \($0)") },
            onClosed: { print("[ExploreApp] CheckoutWidget closed: \($0)") },
            onEventDispatch: { event, data in
                print("[ExploreApp] CheckoutWidget Event: \(event), data: \(data)")
            }
        )
    }

    func elements() -> ElementsCallbacks {
        ElementsCallbacks(
            onSuccess: { data in
                onSaveCardSuccess(data)
            },
            onError: { print("[ExploreApp] ElementsWidget Error: \($0)") },
            onClosed: { print("[ExploreApp] ElementsWidget closed: \($0)") },
            onEventDispatch: { event, data in
                print("[ExploreApp] ElementsWidget Event: \(event), data: \(data)")
            }
        )
    }

    func nextAction() -> NextActionCallbacks {
        NextActionCallbacks(
            onSuccess: { data in
                onPaymentSuccess(data)
            },
            onError: { print("[ExploreApp] NextActionWidget Error: \($0)") },
            onClosed: { print("[ExploreApp] NextActionWidget closed: \($0)") },
            onEventDispatch: { event, data in
                print("[ExploreApp] NextActionWidget Event: \(event), data: \(data)")
            }
        )
    }

    func voucher() -> VoucherCallbacks {
        VoucherCallbacks(
            onSuccess: { data in
                onPaymentSuccess(data)
            },
            onError: { print("[ExploreApp] VoucherWidget Error: \($0)") },
            onClosed: { print("[ExploreApp] VoucherWidget closed: \($0)") },
            onEventDispatch: { event, data in
                print("[ExploreApp] VoucherWidget Event: \(event), data: \(data)")
            }
        )
    }
}
