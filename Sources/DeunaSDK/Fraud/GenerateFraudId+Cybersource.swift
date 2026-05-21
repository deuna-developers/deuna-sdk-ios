//
//  GenerateFraudId+Cybersource.swift
//  DeunaSDK
//
//  Reflection-based: no direct import of RLTMXProfiling.
//  The integrator links the framework by adding DeunaSDKCybersource to their target.
//  DeunaSDK detects it at runtime via NSClassFromString.
//
//  NOTE: We use unsafeBitCast instead of `as? Protocol.Type` because ObjC's
//  conformsToProtocol: requires the class to explicitly declare conformance.
//  RLTMXProfiling does not declare our private mirror protocol, so the `as?`
//  cast would always fail even though the class responds to all selectors.
//
//  NOTE on constants: RLTMXOrgID, RLTMXSessionID, etc. are `EXTERN NSString *const`
//  symbols whose actual string values are obfuscated in the binary. We must resolve
//  them at runtime via dlsym — hardcoding "RLTMXOrgID" as the key value would crash
//  with "Unknown or invalid option(s)".
//

import Darwin
import Foundation

// MARK: - ObjC mirror protocol

/// Mirrors the public interface of RLTMXProfiling without importing the framework.
@objc private protocol _RLTMXProfilingMirror: NSObjectProtocol {
    /// Selector: sharedInstance
    static func sharedInstance() -> NSObject?

    /// Selector: configure:
    func configure(_ config: [AnyHashable: Any])

    /// Selector: profileDeviceUsing:callbackBlock:
    @discardableResult
    func profileDeviceUsing(
        _ profileOptions: [AnyHashable: Any]?,
        callbackBlock: (([AnyHashable: Any]?) -> Void)?
    ) -> AnyObject?
}

// MARK: - Runtime constant resolver

/// Resolves an `EXTERN NSString *const` from the RLTMXProfiling framework.
///
/// The constants' actual string values are obfuscated in the binary — we cannot
/// hardcode them (e.g. `"RLTMXOrgID"` is NOT the key value; the binary stores
/// something like `"ORGhwUWmx"`). We resolve them by:
///   1. Finding the framework's binary path via `Bundle(for:)`.
///   2. Opening it with `dlopen(RTLD_NOLOAD)` (no re-loading, just get handle).
///   3. Calling `dlsym` on that handle to get the symbol's address.
///   4. Dereferencing as `UnsafePointer<NSString>` to read the actual string value.
///
/// Note: `dlsym(nil, ...)` on Darwin only searches the main executable, not
/// all loaded frameworks — so we must use an explicit framework handle.
private func rltmxKey(_ symbolName: String, frameworkClass: AnyClass) -> String? {
    guard
        let execPath = Bundle(for: frameworkClass).executablePath,
        let handle   = dlopen(execPath, RTLD_NOLOAD | RTLD_LAZY)
    else { return nil }
    defer { dlclose(handle) }
    guard let sym = dlsym(handle, symbolName) else { return nil }
    return sym.assumingMemoryBound(to: NSString.self).pointee as String
}

// MARK: - Singleton configure-once guard

private let cybersourceConfigurationLock = NSLock()
private var configuredCybersourceOrgId: String?

// MARK: - Handler

@available(iOS 14.0, *)
extension FraudIdGenerator {
    func runCybersourceNative(config: Json, id: String) {
        guard
            let orgId      = config["orgId"]      as? String, !orgId.isEmpty,
            let merchantId = config["merchantId"] as? String, !merchantId.isEmpty
        else {
            DeunaLogs.warning("[fraud] Missing CYBERSOURCE.orgId or merchantId. Skipping.")
            return
        }

        // 1. Confirm framework is loaded.
        guard let cls = NSClassFromString("RLTMXProfiling") else {
            DeunaLogs.error("[fraud] CYBERSOURCE not linked. Add DeunaSDKCybersource to your target.")
            return
        }

        // 2. Force-cast to protocol type (safe: we verified selectors exist in the binary).
        //    We cannot use `as? _RLTMXProfilingMirror.Type` because ObjC's conformsToProtocol:
        //    requires explicit conformance declaration — which RLTMXProfiling doesn't have for
        //    our private protocol.
        let profilingCls = unsafeBitCast(cls, to: _RLTMXProfilingMirror.Type.self)

        guard let instance = profilingCls.sharedInstance() else {
            DeunaLogs.error("[fraud] CYBERSOURCE RLTMXProfiling.sharedInstance() returned nil.")
            return
        }
        let profiler = unsafeBitCast(instance, to: _RLTMXProfilingMirror.self)

        // 3. Resolve obfuscated constant keys from the loaded framework.
        guard
            let orgIdKey     = rltmxKey("RLTMXOrgID",         frameworkClass: cls),
            let sessionIdKey = rltmxKey("RLTMXSessionID",     frameworkClass: cls),
            let statusKey    = rltmxKey("RLTMXProfileStatus", frameworkClass: cls)
        else {
            DeunaLogs.error("[fraud] CYBERSOURCE constants unavailable (dlsym failed). Check framework linkage.")
            return
        }

        // 4. Configure singleton once — subsequent calls with different orgId are ignored.
        cybersourceConfigurationLock.lock()
        if let already = configuredCybersourceOrgId {
            if already != orgId {
                DeunaLogs.warning("[fraud] CYBERSOURCE already configured with orgId=\(already). Ignoring new orgId=\(orgId).")
            }
        } else {
            var configData: [AnyHashable: Any] = [orgIdKey: orgId]
            if let fpServerKey = rltmxKey("RLTMXFingerprintServer", frameworkClass: cls),
               let fpServer = config["fpServer"] as? String, !fpServer.isEmpty {
                configData[fpServerKey] = fpServer
            }
            profiler.configure(configData)
            configuredCybersourceOrgId = orgId
        }
        cybersourceConfigurationLock.unlock()

        let sessionId = merchantId + id
        DeunaLogs.info("[fraud] CYBERSOURCE profiling started — sessionId=\(sessionId)")

        let semaphore = DispatchSemaphore(value: 0)
        var profilingSucceeded = false

        profiler.profileDeviceUsing(
            [sessionIdKey: sessionId],
            callbackBlock: { result in
                // RLTMXStatusCodeOk = 1 (from TMXStatusCode.h)
                if let statusRaw = result?[statusKey] as? Int {
                    if statusRaw == 1 {
                        profilingSucceeded = true
                        DeunaLogs.info("[fraud] CYBERSOURCE ✔ fraud ID generated — sessionId=\(sessionId)")
                    } else {
                        DeunaLogs.error("[fraud] CYBERSOURCE ✘ profiling failed — statusCode=\(statusRaw) sessionId=\(sessionId)")
                    }
                } else {
                    DeunaLogs.error("[fraud] CYBERSOURCE ✘ profiling returned no status — sessionId=\(sessionId)")
                }
                semaphore.signal()
            }
        )

        let waitResult = semaphore.wait(timeout: .now() + 8)
        if waitResult == .timedOut {
            DeunaLogs.error("[fraud] CYBERSOURCE ✘ profiling timed out after 8s — sessionId=\(sessionId)")
        }
        _ = profilingSucceeded
    }
}
