//
//  GenerateFraudId+Accertify.swift
//  DeunaSDK
//
//  Reflection-based: no direct import of InMobileMME.
//  InMobileMME is a Swift framework — NSClassFromString("InMobileMME.MMEWrapper")
//  or NSClassFromString("MMEWrapper") works because MMEWrapper : NSObject.
//
//  ObjC selectors used:
//    +startOnCompletion:
//    +sendDeviceDataFor:with:onCompletion:
//

import Foundation
import ObjectiveC

// MARK: - ObjC mirror protocol

@objc private protocol _MMEWrapperMirror: NSObjectProtocol {
    /// Start the InMobile SDK. Loads config from InMobile.plist.
    static func startOnCompletion(_ onCompletion: ((Error?) -> Void)?)

    /// Sends device risk log. logs: UInt64.max (ServerLog), with: transactionID.
    static func sendDeviceDataFor(
        _ logs: UInt64,
        with transactionID: String?,
        onCompletion: (([AnyHashable: Any]?, Error?) -> Void)?
    )
}

// MARK: - Handler

@available(iOS 14.0, *)
extension FraudIdGenerator {
    func runAccertifyNative(config: Json, id: String) {
        // 1. Resolve MMEWrapper class at runtime.
        guard let cls = NSClassFromString("InMobileMME.MMEWrapper") ?? NSClassFromString("MMEWrapper") else {
            DeunaLogs.error("[fraud] ACCERTIFY (InMobileMME) not linked. Add DeunaSDKAccertify to your target.")
            return
        }

        // 2. Force-cast class object to mirror protocol to access static methods.
        let wrapperCls = unsafeBitCast(cls, to: _MMEWrapperMirror.Type.self)

        DeunaLogs.info("[fraud] ACCERTIFY starting sequence — sessionId=\(id)")
        let semaphore = DispatchSemaphore(value: 0)

        // 3. Start the SDK (performs registration if first run, loads InMobile.plist).
        wrapperCls.startOnCompletion { error in
            if let error = error {
                DeunaLogs.error("[fraud] ACCERTIFY ✘ start failed — sessionId=\(id) error=\(error.localizedDescription)")
                semaphore.signal()
                return
            }

            DeunaLogs.info("[fraud] ACCERTIFY ✔ started. Sending device data...")

            // 4. Send device logs. logs = UInt64.max (corresponds to InMobileLogSetServerLog).
            wrapperCls.sendDeviceDataFor(UInt64.max, with: id) { result, sendError in
                if let sendError = sendError {
                    DeunaLogs.error("[fraud] ACCERTIFY ✘ sendDeviceData failed — sessionId=\(id) error=\(sendError.localizedDescription)")
                } else {
                    DeunaLogs.info("[fraud] ACCERTIFY ✔ fraud ID generated — sessionId=\(id)")
                }
                semaphore.signal()
            }
        }

        let waitResult = semaphore.wait(timeout: .now() + 8)
        if waitResult == .timedOut {
            DeunaLogs.error("[fraud] ACCERTIFY ✘ sequence timed out after 8s — sessionId=\(id)")
        }
    }
}
