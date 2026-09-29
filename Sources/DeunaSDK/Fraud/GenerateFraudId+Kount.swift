//
//  GenerateFraudId+Kount.swift
//  DeunaSDK
//
//  Reflection-based: no direct import of KountSDK.
//  KountSDK is a Swift @objc framework — NSClassFromString("KDataCollector") works
//  because KDataCollector : NSObject with @objcMembers.
//
//  ObjC selectors used:
//    +shared                                    (class property getter)
//    -setMerchantID:                            (@objc property setter)
//    -setEnvironment:                           (@objc property setter, rawValue Int)
//    -collectForSessionWithSessionID:completion: (@objc method)
//

import Foundation
import ObjectiveC

// MARK: - ObjC mirror protocol

/// Mirrors KDataCollector's public @objc interface.
/// `environment` is typed as Int here — KountEnvironment is @objc enum : Swift.Int,
/// so its ObjC encoding is NSInteger. The rawValues are:
///   0 = KountEnvironment.test
///   1 = KountEnvironment.production
@objc private protocol _KDataCollectorMirror: NSObjectProtocol {
    var merchantID: String { get set }
    var environment: Int   { get set }
    func collectForSession(
        sessionID: String,
        completion: @escaping (String, Bool, Error?) -> Void
    )
}

// MARK: - Handler

@available(iOS 14.0, *)
extension FraudIdGenerator {
    func runKountNative(config: Json, id: String) -> Bool {
        guard let merchantId = config["merchantId"] as? String, !merchantId.isEmpty else {
            DeunaLogs.warning("[fraud] Missing KOUNT.merchantId. Skipping.")
            return false
        }
        let isTest = (config["environment"] as? String ?? "PRODUCTION").uppercased() == "TEST"

        // 1. Resolve KDataCollector class at runtime.
        guard let cls = NSClassFromString("KDataCollector") else {
            DeunaLogs.error("[fraud] KOUNT not linked. Add DeunaSDKKount to your target.")
            return false
        }

        // 2. Get singleton via +shared class method.
        //    unsafeBitCast: ObjC's conformsToProtocol: requires explicit declaration.
        //    KDataCollector doesn't declare our private mirror — use force-cast instead.
        guard
            let sharedRaw = (cls as AnyObject).perform(NSSelectorFromString("shared"))?.takeUnretainedValue()
        else {
            DeunaLogs.error("[fraud] KOUNT KDataCollector.shared unavailable.")
            return false
        }
        let kdc = unsafeBitCast(sharedRaw, to: _KDataCollectorMirror.self)

        // 3. Configure and collect (must happen on main thread per KountSDK requirement).
        let env = isTest ? "TEST" : "PRODUCTION"
        DeunaLogs.info("[fraud] KOUNT collection started — sessionId=\(id) env=\(env)")

        let semaphore = DispatchSemaphore(value: 0)
        var collectionSucceeded = false

        DispatchQueue.main.async {
            kdc.merchantID  = merchantId
            kdc.environment = isTest ? 0 : 1   // KountEnvironment.test=0, .production=1
            kdc.collectForSession(sessionID: id) { _, success, error in
                if let error {
                    DeunaLogs.error("[fraud] KOUNT ✘ collection failed — sessionId=\(id) error=\(error.localizedDescription)")
                } else if success {
                    collectionSucceeded = true
                    DeunaLogs.info("[fraud] KOUNT ✔ fraud ID generated — sessionId=\(id)")
                } else {
                    DeunaLogs.error("[fraud] KOUNT ✘ collection returned success=false — sessionId=\(id)")
                }
                semaphore.signal()
            }
        }

        let waitResult = semaphore.wait(timeout: .now() + 8)
        if waitResult == .timedOut {
            DeunaLogs.error("[fraud] KOUNT ✘ collection timed out after 8s — sessionId=\(id)")
            return false
        }
        return collectionSucceeded
    }
}
