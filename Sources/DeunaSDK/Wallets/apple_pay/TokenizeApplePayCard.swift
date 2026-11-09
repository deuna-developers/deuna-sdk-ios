import Foundation
import PassKit

internal enum TokenizeApplePayCard {

    static func tokenize(
        environment: Environment,
        publicApiKey: String,
        userId: String,
        userToken: String,
        paymentData: [String: Any]
    ) throws -> [String: Any] {
        let encodedUserId = userId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? userId
        let url = "\(environment.config.checkoutBaseUrl)/users/\(encodedUserId)/cards"

        let header = paymentData["header"] as? [String: Any] ?? [:]
        let credentialSourceConfig: [String: Any] = [
            "type": "apple_pay",
            "values": [
                "system": paymentData["version"] as? String ?? "",
                "merchant_transaction_id": header["transactionId"] as? String ?? "",
                "encrypted_data": paymentData["data"] as? String ?? "",
                "encryption_header": [
                    "signature": paymentData["signature"] as? String ?? "",
                    "public_key_hash": header["publicKeyHash"] as? String ?? "",
                    "ephemeral_public_key": header["ephemeralPublicKey"] as? String ?? "",
                ],
                "src_cx_flow_id": "mobile",
            ],
        ]

        let body: [String: Any] = [
            "credential_source": "apple_pay",
            "credential_source_config": credentialSourceConfig,
        ]

        return try DeunaHttpClient.post(
            url: url,
            headers: [
                "Authorization": "Bearer \(userToken)",
                "x-api-key": publicApiKey,
            ],
            body: body
        )
    }

    static func tokenize(
        environment: Environment,
        publicApiKey: String,
        userId: String,
        userToken: String,
        paymentToken: PKPaymentToken
    ) throws -> [String: Any] {
        let paymentData = paymentToken.paymentData.isEmpty
            ? [String: Any]()
            : (try JSONSerialization.jsonObject(with: paymentToken.paymentData) as? [String: Any] ?? [:])
        return try tokenize(
            environment: environment,
            publicApiKey: publicApiKey,
            userId: userId,
            userToken: userToken,
            paymentData: paymentData
        )
    }
}
