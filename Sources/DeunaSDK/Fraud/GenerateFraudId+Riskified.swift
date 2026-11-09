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

/// Mirrors RiskifiedBeacon's static start and update methods.
/// Swift signature:
///   RiskifiedBeacon.startBeacon(_ storeDomain: String, sessionToken: String, debugInfo: Bool)
///   RiskifiedBeacon.updateSessionToken(_ token: String)
/// ObjC selectors:
///   startBeacon:sessionToken:debugInfo:
///   updateSessionToken:
@objc private protocol _RiskifiedBeaconMirror: NSObjectProtocol {
    static func startBeacon(_ storeDomain: String, sessionToken: String, debugInfo: Bool)
    static func updateSessionToken(_ token: String)
}

// MARK: - Beacon Lifecycle State

private let riskifiedLock = NSLock()
private var isRiskifiedBeaconStarted = false

// MARK: - Handler

@available(iOS 14.0, *)
extension FraudIdGenerator {
    func runRiskifiedNative(config: Json, id: String) -> Bool {
        guard let storeDomain = config["storeDomain"] as? String, !storeDomain.isEmpty else {
            DeunaLogs.warning("[fraud] Missing RISKIFIED.storeDomain. Skipping.")
            return false
        }

        // unsafeBitCast: ObjC's conformsToProtocol: requires explicit declaration.
        // RiskifiedBeacon doesn't declare our private mirror — force-cast to bypass the check.
        guard let rawCls = NSClassFromString("RiskifiedBeacon") else {
            DeunaLogs.error("[fraud] RISKIFIED not linked. Add DeunaSDKRiskified to your target.")
            return false
        }
        let cls = unsafeBitCast(rawCls, to: _RiskifiedBeaconMirror.Type.self)

        riskifiedLock.lock()
        let alreadyStarted = isRiskifiedBeaconStarted
        if !alreadyStarted {
            isRiskifiedBeaconStarted = true
        }
        riskifiedLock.unlock()

        let call: () -> Void = {
            if alreadyStarted {
                DeunaLogs.info("[fraud] RISKIFIED updating session token — sessionToken=\(id)")
                cls.updateSessionToken(id)
            } else {
                DeunaLogs.info("[fraud] RISKIFIED beacon starting — domain=\(storeDomain) sessionToken=\(id)")
                cls.startBeacon(storeDomain, sessionToken: id, debugInfo: false)
            }
        }
        Thread.isMainThread ? call() : DispatchQueue.main.sync { call() }

        DeunaLogs.info("[fraud] RISKIFIED ✔ fraud ID generated — domain=\(storeDomain) sessionToken=\(id)")
        return true
    }
}
