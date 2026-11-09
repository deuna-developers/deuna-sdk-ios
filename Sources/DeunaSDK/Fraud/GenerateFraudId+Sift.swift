//
//  GenerateFraudId+Sift.swift
//  DeunaSDK
//
//  Reflection-based: no direct import of Sift.
//  Sift SDK exposes its main class as an ObjC-compatible singleton.
//
//  ObjC selectors used:
//    +sharedInstance   (class method)
//    -setAccountId:    (@objc property setter)
//    -setBeaconKey:    (@objc property setter)
//    -setUserId:       (@objc property setter)
//

import Foundation

// MARK: - ObjC mirror protocol

@objc private protocol _SiftMirror: NSObjectProtocol {
    static func sharedInstance() -> (NSObject & _SiftMirror)?
    var accountId: String { get set }
    var beaconKey: String { get set }
    var userId:    String { get set }
}

// MARK: - Handler

@available(iOS 14.0, *)
extension FraudIdGenerator {
    func runSiftNative(config: Json, id: String) -> Bool {
        guard
            let accountId = config["accountId"] as? String, !accountId.isEmpty,
            let beaconKey = config["beaconKey"] as? String, !beaconKey.isEmpty
        else {
            DeunaLogs.warning("[fraud] Missing SIFT.accountId or beaconKey. Skipping.")
            return false
        }

        // unsafeBitCast: ObjC's conformsToProtocol: requires explicit declaration.
        // Sift class doesn't declare our private mirror — force-cast to bypass the check.
        guard let cls = NSClassFromString("Sift") else {
            DeunaLogs.error("[fraud] SIFT not linked. Add DeunaSDKSift to your target.")
            return false
        }
        let siftCls = unsafeBitCast(cls, to: _SiftMirror.Type.self)
        guard let sift = siftCls.sharedInstance() else {
            DeunaLogs.error("[fraud] SIFT Sift.sharedInstance() returned nil.")
            return false
        }

        DeunaLogs.info("[fraud] SIFT configuration started — userId=\(id)")

        let configure: () -> Void = {
            sift.accountId = accountId
            sift.beaconKey = beaconKey
            sift.userId    = id
        }
        Thread.isMainThread ? configure() : DispatchQueue.main.sync { configure() }

        // Sift does not provide a synchronous completion callback at configuration time.
        // The SDK uploads data autonomously after userId is set.
        DeunaLogs.info("[fraud] SIFT ✔ fraud ID generated — userId=\(id) (upload handled by Sift SDK)")
        return true
    }
}
