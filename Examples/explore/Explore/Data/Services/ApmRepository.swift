import Foundation

struct ApmRepository {
    private static let gistURL = URL(
        string: "https://gist.githubusercontent.com/darwinmorocho-deuna/16d9c3b60cae611bb0027fe82e4b9bcb/raw/mobile_apms_config.json"
    )!

    func fetchIosCompatible() async throws -> [ApmOption] {
        let (data, _) = try await URLSession.shared.data(from: Self.gistURL)
        guard let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return array.compactMap { obj -> ApmOption? in
            let iosCompatible = obj["iosCompatible"] as? Bool ?? true
            guard iosCompatible else { return nil }
            guard
                let paymentMethod = obj["paymentMethod"] as? String,
                let processor = obj["processor"] as? String,
                let logo = obj["logo"] as? String
            else { return nil }
            return ApmOption(
                paymentMethod: paymentMethod,
                processor: processor,
                logo: logo,
                iosCompatible: true,
                androidCompatible: obj["androidCompatible"] as? Bool ?? true
            )
        }
    }
}
