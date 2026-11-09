//
//  GenerateFraudId+MercadoPago.swift
//  DeunaSDK
//
//  Reflection-based: no direct import of MercadoPagoDevicesSDK.
//  The integrator links the framework by adding DeunaSDKMercadoPago to their target.
//  DeunaSDK detects it at runtime via NSClassFromString.
//

import Foundation
#if SWIFT_PACKAGE
import _DeunaSDKObjCBridge
#endif

// MARK: - ObjC mirror protocols

@objc private protocol _MercadoPagoDevicesSDKInstanceMirror: NSObjectProtocol {
    func getInfoAsJsonString() -> String?
}

@objc private protocol _MercadoPagoDevicesSDKClassMirror: NSObjectProtocol {
    static var shared: AnyObject { get }
}

// MARK: - Handler

@available(iOS 14.0, *)
extension FraudIdGenerator {
    func runMercadoPagoNative(config: Json) -> Any? {
        guard let rawCls = NSClassFromString("MercadoPagoDevicesSDK") ?? NSClassFromString("_DeunaSDKMercadoPago.MercadoPagoDevicesSDK") else {
            DeunaLogs.error("[fraud] MERCADOPAGO not linked. Add DeunaSDKMercadoPago to your target.")
            return nil
        }

        let cls = unsafeBitCast(rawCls, to: _MercadoPagoDevicesSDKClassMirror.Type.self)
        let rawInstance = cls.shared
        let instance = unsafeBitCast(rawInstance, to: _MercadoPagoDevicesSDKInstanceMirror.self)

        DeunaLogs.info("[fraud] MERCADOPAGO generating device fingerprint...")

        var jsonString: String?
        var execError: NSString? = nil

        let executed = DeunaPerformSafely({
            jsonString = instance.getInfoAsJsonString()
        }, &execError)

        guard executed, let json = jsonString, !json.isEmpty else {
            DeunaLogs.error("[fraud] MERCADOPAGO ✘ getInfoAsJsonString failed — \(execError ?? "empty result")")
            return nil
        }

        guard let data = json.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: data, options: []) else {
            DeunaLogs.error("[fraud] MERCADOPAGO ✘ failed to parse getInfoAsJsonString output as JSON")
            return nil
        }

        DeunaLogs.info("[fraud] MERCADOPAGO ✔ device fingerprint generated successfully")
        return parsed
    }
}
