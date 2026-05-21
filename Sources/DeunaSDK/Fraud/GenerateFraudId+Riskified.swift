//
//  GenerateFraudId+Riskified.swift
//  DeunaSDK
//
//  Reflection-based: no direct import of RiskifiedBeacon.
//  RiskifiedBeacon exposes a static +start:sessionToken:debugInfo: class method.
//
//  ObjC selector used:
//    +start:sessionToken:debugInfo:   (class method, first arg has no label in Swift)
//

import Foundation

// MARK: - ObjC mirror protocol

/// Mirrors RiskifiedBeacon's static start method.
/// Swift signature: RiskifiedBeacon.startBeacon(_ storeDomain: String, sessionToken: String, debugInfo: Bool)
/// ObjC selector:   startBeacon:sessionToken:debugInfo:
@objc private protocol _RiskifiedBeaconMirror: NSObjectProtocol {
    static func startBeacon(_ storeDomain: String, sessionToken: String, debugInfo: Bool)
}

// MARK: - Handler

@available(iOS 14.0, *)
extension FraudIdGenerator {
    func runRiskifiedNative(config: Json, id: String) {
        guard let storeDomain = config["storeDomain"] as? String, !storeDomain.isEmpty else {
            DeunaLogs.warning("[fraud] Missing RISKIFIED.storeDomain. Skipping.")
            return
        }

        // unsafeBitCast: ObjC's conformsToProtocol: requires explicit declaration.
        // RiskifiedBeacon doesn't declare our private mirror — force-cast to bypass the check.
        guard let rawCls = NSClassFromString("RiskifiedBeacon") else {
            DeunaLogs.error("[fraud] RISKIFIED not linked. Add DeunaSDKRiskified to your target.")
            return
        }
        let cls = unsafeBitCast(rawCls, to: _RiskifiedBeaconMirror.Type.self)

        DeunaLogs.info("[fraud] RISKIFIED beacon starting — domain=\(storeDomain) sessionToken=\(id)")

        let call: () -> Void = {
            cls.startBeacon(storeDomain, sessionToken: id, debugInfo: false)
        }
        Thread.isMainThread ? call() : DispatchQueue.main.sync { call() }

        // RiskifiedBeacon.start does not throw or return a status — a successful
        // call means the beacon session was started and data will be uploaded by the SDK.
        DeunaLogs.info("[fraud] RISKIFIED ✔ fraud ID generated — domain=\(storeDomain) sessionToken=\(id)")
    }
}
