//
//  TestNotificationHelper.swift
//  Explore
//
//  Created for integration testing support
//

import Foundation

/// Utility used by the sample app to broadcast test-only Darwin notifications.
/// This allows UI tests to synchronize with SDK events emitted by the app process.
class TestNotificationHelper {

    /// Canonical event names consumed by integration tests.
    enum TestEvent: String {
        case checkoutStarted = "com.deuna.checkoutStarted"
        case paymentMethodsEntered = "com.deuna.paymentMethodsEntered"

        var notificationName: CFNotificationName {
            return CFNotificationName(self.rawValue as CFString)
        }
    }

    /// Posts a Darwin notification that can be observed across process boundaries
    /// - Parameter event: The test event to post
    static func post(_ event: TestEvent) {
        print("🔔 [TestNotification] Posting: \(event.rawValue)")
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            event.notificationName,
            nil,
            nil,
            true
        )
        print("🔔 [TestNotification] Posted successfully: \(event.rawValue)")
    }

    /// Posts a custom Darwin notification with a specific name
    /// - Parameter name: Custom notification name (will be prefixed with com.deuna.)
    static func postCustom(_ name: String) {
        let fullName = "com.deuna.\(name)"
        print("🔔 [TestNotification] Posting custom: \(fullName)")
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(fullName as CFString),
            nil,
            nil,
            true
        )
    }
}
