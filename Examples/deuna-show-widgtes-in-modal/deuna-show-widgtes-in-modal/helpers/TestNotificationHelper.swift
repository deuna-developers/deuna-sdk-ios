//
//  TestNotificationHelper.swift
//  deuna-show-widgtes-in-modal
//
//  Created for integration testing support
//

import Foundation

/// Helper class for sending Darwin Notifications that work across process boundaries
/// Useful for UI tests to observe events from the main app process
class TestNotificationHelper {
    
    /// Notification names used for testing
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
