//
//  GenerateFraudId.swift
//  DeunaSDK
//
//  Created by deuna on 9/4/25.
//

import Foundation
#if canImport(RiskifiedBeacon)
import RiskifiedBeacon
#endif
#if canImport(RLTMXProfiling)
import RLTMXProfiling
#endif

@available(iOS 14.0, *)
public extension DeunaSDK {
    /// Public API intentionally unchanged to avoid breaking integrators.
    func generateFraudId(params: Json? = nil, completion: @escaping (String?) -> Void) {
        _ = FraudIdGenerator(params: params, callback: completion)
    }
}

@available(iOS 14.0, *)
private enum FraudProviderName: String {
    case riskified = "RISKIFIED"
    case cybersource = "CYBERSOURCE"

    static func from(_ raw: String) -> FraudProviderName? {
        FraudProviderName(rawValue: raw.uppercased())
    }
}

@available(iOS 14.0, *)
private struct FraudProviderRequest {
    let name: FraudProviderName
    let config: Json
}

@available(iOS 14.0, *)
private typealias FraudProviderHandler = (_ config: Json, _ id: String) -> Void

@available(iOS 14.0, *)
final class FraudIdGenerator {
    private let params: Json?
    private let callback: (String?) -> Void
    private let providersQueue = DispatchQueue(
        label: "io.deuna.fraud.providers",
        qos: .userInitiated,
        attributes: .concurrent
    )
    private static let cybersourceConfigurationLock = NSLock()
    private static var configuredCybersourceOrgId: String?

    private lazy var handlers: [FraudProviderName: FraudProviderHandler] = [
        .riskified: runRiskifiedNative,
        .cybersource: runCybersourceNative
    ]

    init(params: Json?, callback: @escaping (String?) -> Void) {
        self.params = params
        self.callback = callback
        run()
    }

    private func run() {
        let requests = parseRequests(from: params)
        if requests.isEmpty {
            callback(nil)
            return
        }
        
        DeunaLogs.info("GENERATING FRAUD ID")

        // Build ID map first so returned fraudId is deterministic and provider-agnostic.
        var result: [String: String] = [:]
        for request in requests {
            result[request.name.rawValue] = UUID().uuidString.lowercased()
        }

        let group = DispatchGroup()
        for request in requests {
            guard let id = result[request.name.rawValue], let handler = handlers[request.name] else {
                continue
            }
            group.enter()
            providersQueue.async {
                handler(request.config, id)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.callback(result.base64String())
        }
    }

    private func parseRequests(from params: Json?) -> [FraudProviderRequest] {
        guard let params else { return [] }

        var requests: [FraudProviderRequest] = []

        for (rawKey, value) in params {
            guard let provider = FraudProviderName.from(rawKey) else {
                DeunaLogs.warning("[fraud] Unsupported provider \(rawKey). Ignoring.")
                continue
            }
            guard let config = value as? Json else {
                DeunaLogs.warning("[fraud] Invalid config for \(provider.rawValue). Expected object.")
                continue
            }
            requests.append(FraudProviderRequest(name: provider, config: config))
        }

        return requests
    }

    private func runRiskifiedNative(config: Json, id: String) {
        guard let storeDomain = config["storeDomain"] as? String, !storeDomain.isEmpty else {
            DeunaLogs.warning("[fraud] Missing RISKIFIED.storeDomain. Skipping native init.")
            return
        }

        #if canImport(RiskifiedBeacon)
        if Thread.isMainThread {
            RiskifiedBeacon.start(storeDomain, sessionToken: id, debugInfo: false)
        } else {
            DispatchQueue.main.sync {
                RiskifiedBeacon.start(storeDomain, sessionToken: id, debugInfo: false)
            }
        }
        #else
        DeunaLogs.warning("[fraud] RiskifiedBeacon SDK is not linked in this build.")
        #endif
    }

    private func runCybersourceNative(config: Json, id: String) {
        guard
            let orgId = config["orgId"] as? String, !orgId.isEmpty,
            let merchantId = config["merchantId"] as? String, !merchantId.isEmpty
        else {
            DeunaLogs.warning("[fraud] Missing CYBERSOURCE.orgId or merchantId. Skipping native init.")
            return
        }

        #if canImport(RLTMXProfiling)
        guard let profiler = RLTMXProfiling.sharedInstance() else {
            DeunaLogs.warning("[fraud] RLTMXProfiling shared instance unavailable.")
            return
        }

        FraudIdGenerator.configureCybersourceIfNeeded(profiler: profiler, orgId: orgId)

        let sessionId = merchantId + id
        let options: [AnyHashable: Any] = [
            RLTMXSessionID: sessionId
        ]

        let semaphore = DispatchSemaphore(value: 0)
        _ = profiler.profileDevice(profileOptions: options) { result in
            if let status = result?[RLTMXProfileStatus] {
                DeunaLogs.info("[fraud] CYBERSOURCE profile status: \(status)")
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + 8)
        #else
        DeunaLogs.warning("[fraud] RLTMXProfiling SDK is not linked in this build.")
        #endif
    }

    #if canImport(RLTMXProfiling)
    private static func configureCybersourceIfNeeded(profiler: RLTMXProfiling, orgId: String) {
        cybersourceConfigurationLock.lock()
        defer { cybersourceConfigurationLock.unlock() }

        if let configured = configuredCybersourceOrgId {
            if configured != orgId {
                DeunaLogs.warning("[fraud] CYBERSOURCE already configured with orgId \(configured). Ignoring new orgId \(orgId).")
            }
            return
        }

        let configData: [AnyHashable: Any] = [
            RLTMXOrgID: orgId
        ]
        profiler.configure(configData: configData)
        configuredCybersourceOrgId = orgId
    }
    #endif
}
