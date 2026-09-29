//
//  GenerateFraudId+Signifyd.swift
//  DeunaSDK
//
//  Reflection-based: no direct import of TMXProfiling.
//  The integrator links the framework by adding DeunaSDKSignifyd to their target.
//  DeunaSDK detects it at runtime via NSClassFromString.
//
//  NOTE: We use unsafeBitCast instead of `as? Protocol.Type` because ObjC's
//  conformsToProtocol: requires the class to explicitly declare conformance.
//  TMXProfiling does not declare our private mirror protocol, so the `as?`
//  cast would always fail even though the class responds to all selectors.
//
//  NOTE on constants: TMXOrgID, TMXSessionID, etc. are `EXTERN NSString *const`
//  symbols whose actual string values are obfuscated in the binary. We must resolve
//  them at runtime via dlsym — hardcoding "TMXOrgID" as the key value would crash
//  with "Unknown or invalid option(s)".
//

import Darwin
import Foundation
#if SWIFT_PACKAGE
import _DeunaSDKObjCBridge
#endif

// MARK: - ObjC mirror protocols

/// Mirrors the public interface of TMXProfiling without importing the framework.
@objc private protocol _TMXProfilingMirror: NSObjectProtocol {
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

/// Mirrors TMXProfilingConnections — instantiated via ObjC runtime alloc/init.
@objc private protocol _TMXProfilingConnectionsMirror: NSObjectProtocol {
    init()
}

// MARK: - Runtime constant resolver

/// Resolves an `EXTERN NSString *const` from the TMXProfiling framework.
///
/// The constants' actual string values are obfuscated in the binary — we cannot
/// hardcode them. We resolve them by:
///   1. Finding the framework's binary path via `Bundle(for:)`.
///   2. Opening it with `dlopen(RTLD_NOLOAD)` (no re-loading, just get handle).
///   3. Calling `dlsym` on that handle to get the symbol's address.
///   4. Dereferencing as `UnsafePointer<NSString>` to read the actual string value.
private func tmxKey(_ symbolName: String, frameworkClass: AnyClass) -> String? {
    guard
        let execPath = Bundle(for: frameworkClass).executablePath,
        let handle   = dlopen(execPath, RTLD_NOLOAD | RTLD_LAZY)
    else { return nil }
    defer { dlclose(handle) }
    guard let sym = dlsym(handle, symbolName) else { return nil }
    return sym.assumingMemoryBound(to: NSString.self).pointee as String
}

// MARK: - Singleton configure-once guard

private let signifydConfigurationLock = NSLock()
private var configuredSignifydOrgId: String?

// MARK: - Handler

@available(iOS 14.0, *)
extension FraudIdGenerator {
    func runSignifydNative(config: Json, id: String) -> Bool {
        guard
            let orgId = config["orgId"] as? String, !orgId.isEmpty
        else {
            DeunaLogs.warning("[fraud] Missing SIGNIFYD.orgId. Skipping.")
            return false
        }

        let fpServer = (config["fpServer"] as? String).flatMap { $0.isEmpty ? nil : $0 }
            ?? "imgs.signifyd.com"

        // 1. Confirm framework is loaded.
        guard let cls = NSClassFromString("TMXProfiling") else {
            DeunaLogs.error("[fraud] SIGNIFYD not linked. Add DeunaSDKSignifyd to your target.")
            return false
        }

        // 2. Force-cast to protocol type (safe: we verified selectors exist in the binary).
        let profilingCls = unsafeBitCast(cls, to: _TMXProfilingMirror.Type.self)

        guard let instance = profilingCls.sharedInstance() else {
            DeunaLogs.error("[fraud] SIGNIFYD TMXProfiling.sharedInstance() returned nil.")
            return false
        }
        let profiler = unsafeBitCast(instance, to: _TMXProfilingMirror.self)

        // 3. Resolve obfuscated constant keys from the loaded framework.
        guard
            let orgIdKey       = tmxKey("TMXOrgID",           frameworkClass: cls),
            let fpServerKey    = tmxKey("TMXFingerprintServer", frameworkClass: cls),
            let sessionIdKey   = tmxKey("TMXSessionID",        frameworkClass: cls),
            let statusKey      = tmxKey("TMXProfileStatus",    frameworkClass: cls),
            let connectionsKey = tmxKey("TMXProfilingConnectionsInstance", frameworkClass: cls)
        else {
            DeunaLogs.error("[fraud] SIGNIFYD constants unavailable (dlsym failed). Check framework linkage.")
            return false
        }

        // 4. Instantiate TMXProfilingConnections via ObjC runtime alloc/init.
        var connectionsInstance: AnyObject? = nil
        if let connCls = NSClassFromString("TMXProfilingConnections") {
            let allocated = (connCls as AnyObject).perform(NSSelectorFromString("alloc"))?.takeUnretainedValue()
            connectionsInstance = allocated?.perform(NSSelectorFromString("init"))?.takeUnretainedValue()
        }

        // 5. Configure singleton once.
        signifydConfigurationLock.lock()
        if let already = configuredSignifydOrgId {
            if already != orgId {
                DeunaLogs.warning("[fraud] SIGNIFYD already configured with orgId=\(already). Ignoring new orgId=\(orgId).")
            }
        } else {
            var configData: [AnyHashable: Any] = [
                orgIdKey:    orgId,
                fpServerKey: fpServer,
            ]
            if let conn = connectionsInstance {
                configData[connectionsKey] = conn
            }
            var configError: NSString? = nil
            let configured = DeunaPerformSafely({
                profiler.configure(configData)
            }, &configError)
            if configured {
                configuredSignifydOrgId = orgId
            } else {
                DeunaLogs.error("[fraud] SIGNIFYD ✘ configure failed — \(configError ?? "unknown error")")
                signifydConfigurationLock.unlock()
                return false
            }
        }
        signifydConfigurationLock.unlock()

        let sessionId = id
        DeunaLogs.info("[fraud] SIGNIFYD profiling started — sessionId=\(sessionId)")

        let semaphore = DispatchSemaphore(value: 0)
        var profilingSucceeded = false

        var profileError: NSString? = nil
        let profileCalled = DeunaPerformSafely({
            profiler.profileDeviceUsing(
                [sessionIdKey: sessionId],
                callbackBlock: { result in
                    // TMXStatusCodeOk = 1 (from TMXStatusCode.h)
                    if let statusRaw = result?[statusKey] as? Int {
                        if statusRaw == 1 {
                            profilingSucceeded = true
                            DeunaLogs.info("[fraud] SIGNIFYD ✔ fraud ID generated — sessionId=\(sessionId)")
                        } else {
                            DeunaLogs.error("[fraud] SIGNIFYD ✘ profiling failed — statusCode=\(statusRaw) sessionId=\(sessionId)")
                        }
                    } else {
                        DeunaLogs.error("[fraud] SIGNIFYD ✘ profiling returned no status — sessionId=\(sessionId)")
                    }
                    semaphore.signal()
                }
            )
        }, &profileError)
        if !profileCalled {
            DeunaLogs.error("[fraud] SIGNIFYD ✘ profileDevice threw exception — \(profileError ?? "unknown error")")
            return false
        }

        let waitResult = semaphore.wait(timeout: .now() + 8)
        if waitResult == .timedOut {
            DeunaLogs.error("[fraud] SIGNIFYD ✘ profiling timed out after 8s — sessionId=\(sessionId)")
            return false
        }
        return profilingSucceeded
    }
}
