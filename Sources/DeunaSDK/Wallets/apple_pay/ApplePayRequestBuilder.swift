import Foundation
import PassKit

internal enum ApplePayRequestBuilder {

    static func build(_ credentials: ApplePayCredentials) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = credentials.merchantIdentifier
        request.supportedNetworks = toPassKitNetworks(credentials.supportedNetworks)
        request.merchantCapabilities = toMerchantCapabilities(credentials.merchantCapabilities)

        if let info = credentials.transactionInfo {
            request.countryCode = info.countryCode
            request.currencyCode = info.currencyCode
            let amount = NSDecimalNumber(string: info.amount)
            request.paymentSummaryItems = [
                PKPaymentSummaryItem(label: info.label, amount: amount)
            ]
        } else {
            request.paymentSummaryItems = [
                PKPaymentSummaryItem(
                    label: credentials.displayName,
                    amount: NSDecimalNumber.zero,
                    type: .pending
                )
            ]
        }

        return request
    }

    private static func toPassKitNetworks(_ names: [String]) -> [PKPaymentNetwork] {
        return names.compactMap { name in
            switch name.uppercased() {
            case "VISA": return .visa
            case "MASTERCARD": return .masterCard
            case "AMEX": return .amex
            case "DISCOVER": return .discover
            case "JCB": return .JCB
            case "INTERAC": return .interac
            case "MAESTRO":
                if #available(iOS 12.0, *) { return .maestro }
                return nil
            case "CHINAUP", "CHINAUNIONPAY": return .chinaUnionPay
            default: return nil
            }
        }
    }

    private static func toMerchantCapabilities(_ names: [String]) -> PKMerchantCapability {
        var caps: PKMerchantCapability = []
        for name in names {
            switch name.uppercased() {
            case "CRYPTOGRAM_3DS": caps.insert(.capability3DS)
            case "PAN_ONLY": caps.insert(.capabilityEMV)
            case "DEBIT": caps.insert(.capabilityDebit)
            case "CREDIT": caps.insert(.capabilityCredit)
            default: break
            }
        }
        return caps.isEmpty ? .capability3DS : caps
    }
}
