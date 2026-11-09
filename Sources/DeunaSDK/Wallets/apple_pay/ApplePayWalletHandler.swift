import Foundation
import PassKit

internal class ApplePayWalletHandler: NSObject, WalletHandler, PKPaymentAuthorizationControllerDelegate {

    static let shared = ApplePayWalletHandler()

    private var pendingCredentials: ApplePayCredentials?
    private var pendingCompletion: ((WalletLaunchResult) -> Void)?
    private var paymentCompleted = false
    private var activeController: PKPaymentAuthorizationController?

    // MARK: - WalletHandler

    var provider: WalletProvider { .applePay }

    func isAvailableOnDevice() -> Bool {
        let networks = ApplePayCredentials.defaultNetworks.compactMap { toPassKitNetwork($0) }
        let canMakePayments = PKPaymentAuthorizationController.canMakePayments()
        let canMakePaymentsUsingNetworks = PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: networks
        )
        return canMakePayments && canMakePaymentsUsingNetworks
    }

    func launch(
        credentials: WalletCredentials,
        completion: @escaping (WalletLaunchResult) -> Void
    ) {
        guard let applePayCredentials = credentials as? ApplePayCredentials else {
            completion(.error(code: "NO_APPLE_PAY_CREDENTIALS", message: "No Apple Pay configuration found."))
            return
        }

        guard !applePayCredentials.merchantIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.error(
                code: "APPLE_PAY_MISSING_MERCHANT_ID",
                message: "Apple Pay credentials are missing merchantIdentifier."
            ))
            return
        }

        pendingCredentials = applePayCredentials
        pendingCompletion = completion
        paymentCompleted = false

        let request = ApplePayRequestBuilder.build(applePayCredentials)

        DispatchQueue.main.async {
            let controller = PKPaymentAuthorizationController(paymentRequest: request)
            controller.delegate = self
            self.activeController = controller
            controller.present { presented in
                if !presented {
                    self.activeController = nil
                    completion(.error(
                        code: "APPLE_PAY_PRESENT_FAILED",
                        message: "Apple Pay sheet could not be presented."
                    ))
                    self.clearPending()
                }
            }
        }
    }

    // MARK: - PKPaymentAuthorizationControllerDelegate

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        let walletCompletion = pendingCompletion
        paymentCompleted = true

        let rawPaymentData = (try? JSONSerialization.jsonObject(with: payment.token.paymentData) as? [String: Any]) ?? [:]
        DispatchQueue.main.async {
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            walletCompletion?(.success(["paymentData": rawPaymentData]))
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            let completion = self.pendingCompletion
            let completed = self.paymentCompleted
            self.clearPending()
            if !completed {
                DispatchQueue.main.async { completion?(.closed) }
            }
        }
    }

    // MARK: - Helpers

    private func clearPending() {
        pendingCredentials = nil
        pendingCompletion = nil
        activeController = nil
    }

    private func toPassKitNetwork(_ name: String) -> PKPaymentNetwork? {
        switch name.uppercased() {
        case "VISA": return .visa
        case "MASTERCARD": return .masterCard
        case "AMEX": return .amex
        case "DISCOVER": return .discover
        case "JCB": return .JCB
        case "INTERAC": return .interac
        default: return nil
        }
    }
}
