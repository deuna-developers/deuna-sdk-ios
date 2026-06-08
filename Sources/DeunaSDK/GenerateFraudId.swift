//
//  GenerateFraudId.swift
//  DeunaSDK
//
//  Created by deuna on 9/4/25.
//

import Foundation

@available(iOS 14.0, *)
public extension DeunaSDK {
    /// Public API intentionally unchanged to avoid breaking integrators.
    func generateFraudId(params: Json? = nil, completion: @escaping (String?) -> Void) {
        _ = FraudIdGenerator(params: params, callback: completion)
    }
}

@available(iOS 14.0, *)
enum FraudProviderName: String {
    case riskified = "RISKIFIED"
    case cybersource = "CYBERSOURCE"
    case sift = "SIFT"
    case kount = "KOUNT"
    case signifyd = "SIGNIFYD"
    case accertify = "ACCERTIFY"

    static func from(_ raw: String) -> FraudProviderName? {
        FraudProviderName(rawValue: raw.uppercased())
    }
}

@available(iOS 14.0, *)
struct FraudProviderRequest {
    let name: FraudProviderName
    let config: Json
}

@available(iOS 14.0, *)
typealias FraudProviderHandler = (_ config: Json, _ id: String) -> Void

@available(iOS 14.0, *)
final class FraudIdGenerator {
    private let params: Json?
    private let callback: (String?) -> Void
    let providersQueue = DispatchQueue(
        label: "io.deuna.fraud.providers",
        qos: .userInitiated,
        attributes: .concurrent
    )

    private lazy var handlers: [FraudProviderName: FraudProviderHandler] = [
        .riskified:   self.runRiskifiedNative,
        .cybersource: self.runCybersourceNative,
        .sift:        self.runSiftNative,
        .kount:       self.runKountNative,
        .signifyd:    self.runSignifydNative,
        .accertify:   self.runAccertifyNative,
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
}
