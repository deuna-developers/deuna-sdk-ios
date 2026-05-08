import Foundation

enum DeunaHttpMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

enum DeunaHttpClient {
    static func get(url: String, headers: [String: String]) throws -> [String: Any] {
        return try request(method: .GET, url: url, headers: headers)
    }

    static func post(url: String, headers: [String: String], body: [String: Any]? = nil) throws -> [String: Any] {
        return try request(method: .POST, url: url, headers: headers, body: body)
    }

    private static func request(
        method: DeunaHttpMethod,
        url: String,
        headers: [String: String],
        body: [String: Any]? = nil
    ) throws -> [String: Any] {
        guard let requestUrl = URL(string: url) else {
            throw NSError(
                domain: "DeunaHttpClient",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(url)"]
            )
        }

        var urlRequest = URLRequest(url: requestUrl)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        if let body = body {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let semaphore = DispatchSemaphore(value: 0)
        var result: [String: Any]?
        var requestError: Error?

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            defer { semaphore.signal() }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            DeunaLogs.info("[http] \(method.rawValue) \(url) → \(statusCode)")

            if let error = error {
                requestError = error
                return
            }
            guard let data = data else {
                requestError = NSError(
                    domain: "DeunaHttpClient",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "No data received"]
                )
                return
            }
            do {
                result = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            } catch {
                requestError = error
            }
        }.resume()

        semaphore.wait()

        if let error = requestError { throw error }
        return result ?? [:]
    }
}
