import XCTest
@testable import DeunaSDK

final class DeunaSDKTests: XCTestCase {

    func testSharedInstance() {
        let instance = DeunaSDK.shared
        XCTAssertNotNil(instance, "Shared instance of DeunaSDK should not be nil.")
    }

    func testConfig() {
        let apiKey = "testApiKey"
        let orderToken = "testOrderToken"
        let userToken = "testUserToken"
        let environment: Environment = .development
        let closeButtonConfig = CloseButtonConfig()

        DeunaSDK.config(apiKey: apiKey, orderToken: orderToken, userToken: userToken, environment: environment, closeButtonConfig: closeButtonConfig)

        XCTAssertEqual(DeunaSDK.shared.apiKey, apiKey, "API Key should be set correctly.")
        XCTAssertEqual(DeunaSDK.shared.orderToken, orderToken, "Order Token should be set correctly.")
        XCTAssertEqual(DeunaSDK.shared.userToken, userToken, "User Token should be set correctly.")
        XCTAssertEqual(DeunaSDK.shared.environment, environment, "Environment should be set correctly.")
        XCTAssertEqual(DeunaSDK.shared.closeButtonConfig?.title, closeButtonConfig.title, "CloseButtonConfig should be set correctly.")
    }

    func testEnableLogging() {
        DeunaSDK.shared.enableLogging()
        XCTAssertTrue(DeunaSDK.shared.isLoggingEnabled, "Logging should be enabled.")
    }

    func testDisableLogging() {
        DeunaSDK.shared.disableLogging()
        XCTAssertFalse(DeunaSDK.shared.isLoggingEnabled, "Logging should be disabled.")
    }

    func testNetworkAvailability() {
        let isAvailable = DeunaSDK.shared.isNetworkAvailable
        // This test might need adjustments based on the actual network conditions during testing.
        XCTAssertTrue(isAvailable, "Network should be available.")
    }

    // This is a helper method to create a mock view for testing purposes.
    private func createMockView() -> UIView {
        return UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    func testInitCheckoutWithoutConfig() {
        // Given
        let sdk = DeunaSDK.shared
        let callbacks = DeunaSDK.Callbacks()
        
        // When & Then
        XCTAssertThrowsError(try sdk.initCheckout(callbacks: callbacks), "Expected to throw an assertion error when calling `initCheckout` without configuring the SDK first.")
    }
}
