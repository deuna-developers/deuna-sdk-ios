import Foundation

/// Handles merchant profile retrieval using the private API key.
final class MerchantService {
    enum ServiceError: LocalizedError {
        case invalidURL
        case invalidResponse
        case merchantProfileNotFound
        case api(message: String)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL."
            case .invalidResponse:
                return "Unexpected API response."
            case .merchantProfileNotFound:
                return "Unable to fetch merchant information with the provided private key."
            case .api(let message):
                return message
            }
        }
    }

    func loadMerchantProfile(
        environment: ExploreEnvironment,
        privateKey: String
    ) async throws -> ExploreMerchantProfile {
        guard let url = URL(string: "\(environment.apiBaseURL)/merchants") else {
            throw ServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(privateKey, forHTTPHeaderField: "X-Api-Key")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ServiceError.api(
                message: apiMessage(from: data) ?? "Merchant request failed (\(httpResponse.statusCode)).")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ServiceError.invalidResponse
        }

        let root = (json["data"] as? [String: Any]) ?? json
        let name =
            (root["merchant_name"] as? String)
            ?? (root["name"] as? String)
            ?? ""
        let countryCode =
            ((root["country_iso"] as? String)
            ?? (root["country_code"] as? String)
                ?? (root["country"] as? String)
                    ?? "US")
            .uppercased()
        let currencyCode =
            ((root["currency_iso"] as? String)
            ?? (root["currency"] as? String)
                ?? "USD")
            .uppercased()

        if countryCode.isEmpty || currencyCode.isEmpty {
            throw ServiceError.merchantProfileNotFound
        }

        return ExploreMerchantProfile(
            name: name,
            countryCode: countryCode,
            currencyCode: currencyCode
        )
    }

    private func apiMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return (json["message"] as? String) ?? (json["error"] as? String)
    }
}
