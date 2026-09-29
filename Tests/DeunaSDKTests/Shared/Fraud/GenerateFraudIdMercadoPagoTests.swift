import XCTest
@testable import DeunaSDK

@available(iOS 14.0, *)
final class GenerateFraudIdMercadoPagoTests: XCTestCase {
    func testFraudProviderEnumMercadoPago() {
        XCTAssertEqual(FraudProviderName.from("MERCADOPAGO"), .mercadoPago)
        XCTAssertEqual(FraudProviderName.from("mercadopago"), .mercadoPago)
        XCTAssertEqual(FraudProviderName.mercadoPago.rawValue, "MERCADOPAGO")
    }

    func testGenerateFraudIdGracefullyHandlesUnlinkedMercadoPago() {
        let exp = expectation(description: "Fraud ID callback")
        let sdk = DeunaSDK(environment: .sandbox, publicApiKey: "test_key")

        sdk.generateFraudId(params: ["MERCADOPAGO": [:]]) { fraudId in
            // MERCADOPAGO not linked -> does not crash, completes callback safely
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
    }
}
