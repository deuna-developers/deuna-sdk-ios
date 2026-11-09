import Foundation

/// Handles app-side tokenization flow:
/// 1) fetch merchant profile from private key
/// 2) build a simple order payload from local products
/// 3) request `/merchants/orders` and return the generated order token.
final class OrderTokenService {
    private let merchantService: MerchantService

    init(merchantService: MerchantService = MerchantService()) {
        self.merchantService = merchantService
    }

    private struct TokenizeOrderRequest: Encodable {
        let orderType: String
        let order: OrderData

        enum CodingKeys: String, CodingKey {
            case orderType = "order_type"
            case order
        }
    }

    private struct OrderData: Encodable {
        let orderId: String
        let storeCode: String
        let currency: String
        let taxAmount: Int
        let shippingAmount: Int
        let itemsTotalAmount: Int
        let subTotal: Int
        let totalAmount: Int
        let displayTotalAmount: String
        let items: [OrderItem]
        let discounts: [OrderDiscount]
        let shippingAddress: OrderAddress
        let billingAddress: OrderAddress
        let status: String
        let timezone: String

        enum CodingKeys: String, CodingKey {
            case orderId = "order_id"
            case storeCode = "store_code"
            case currency
            case taxAmount = "tax_amount"
            case shippingAmount = "shipping_amount"
            case itemsTotalAmount = "items_total_amount"
            case subTotal = "sub_total"
            case totalAmount = "total_amount"
            case displayTotalAmount = "display_total_amount"
            case items
            case discounts
            case shippingAddress = "shipping_address"
            case billingAddress = "billing_address"
            case status
            case timezone
        }
    }

    private struct OrderItem: Encodable {
        let id: String
        let name: String
        let description: String
        let quantity: Int
        let sku: String
        let category: String
        let totalAmount: AmountPayload
        let unitPrice: AmountPayload

        enum CodingKeys: String, CodingKey {
            case id, name, description, quantity, sku, category
            case totalAmount = "total_amount"
            case unitPrice = "unit_price"
        }
    }

    private struct AmountPayload: Encodable {
        let amount: Int
        let displayAmount: String

        enum CodingKeys: String, CodingKey {
            case amount
            case displayAmount = "display_amount"
        }
    }

    private struct OrderDiscount: Encodable {
        let amount: Int
        let code: String
        let description: String
        let discountCategory: String

        enum CodingKeys: String, CodingKey {
            case amount, code, description
            case discountCategory = "discount_category"
        }
    }

    private struct OrderAddress: Encodable {
        let firstName: String
        let lastName: String
        let phone: String
        let identityDocument: String
        let lat: Double
        let lng: Double
        let address1: String
        let address2: String
        let city: String
        let zipcode: String
        let stateName: String
        let country: String
        let countryCode: String
        let email: String

        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
            case phone
            case identityDocument = "identity_document"
            case lat, lng
            case address1, address2, city, zipcode
            case stateName = "state_name"
            case country
            case countryCode = "country_code"
            case email
        }
    }

    private struct AddressSeed {
        let city: String
        let stateName: String
        let countryName: String
        let countryCode: String
        let zipcode: String
        let lat: Double
        let lng: Double
    }

    enum ServiceError: LocalizedError {
        case invalidURL
        case invalidResponse
        case tokenNotFound
        case api(message: String)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL."
            case .invalidResponse:
                return "Unexpected API response."
            case .tokenNotFound:
                return "Order token was not returned by the API."
            case .api(let message):
                return message
            }
        }
    }

    func createOrderToken(
        environment: ExploreEnvironment,
        privateKey: String,
        products: [ExploreProduct]
    ) async throws -> OrderTokenResult {
        let merchantProfile = try await loadMerchantProfile(
            environment: environment,
            privateKey: privateKey
        )
        let orderPayload = buildOrderPayload(
            merchantProfile: merchantProfile,
            products: products
        )
        let orderToken = try await tokenizeOrder(
            environment: environment,
            privateKey: privateKey,
            payload: orderPayload
        )
        return OrderTokenResult(orderToken: orderToken, merchantProfile: merchantProfile)
    }

    func loadMerchantProfile(
        environment: ExploreEnvironment,
        privateKey: String
    ) async throws -> ExploreMerchantProfile {
        try await merchantService.loadMerchantProfile(
            environment: environment,
            privateKey: privateKey
        )
    }

    private func tokenizeOrder(
        environment: ExploreEnvironment,
        privateKey: String,
        payload: TokenizeOrderRequest
    ) async throws -> String {
        guard let url = URL(string: "\(environment.apiBaseURL)/merchants/orders") else {
            throw ServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(privateKey, forHTTPHeaderField: "X-Api-Key")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ServiceError.api(
                message: apiMessage(from: data) ?? "Order tokenization failed (\(httpResponse.statusCode))."
            )
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let token = json["token"] as? String,
            !token.isEmpty
        else {
            throw ServiceError.tokenNotFound
        }

        return token
    }

    private func buildOrderPayload(
        merchantProfile: ExploreMerchantProfile,
        products: [ExploreProduct]
    ) -> TokenizeOrderRequest {
        let normalizedCurrency = merchantProfile.currencyCode.uppercased()
        let decimals = currencyUsesZeroDecimals(normalizedCurrency) ? 0 : 2
        let totalAmount = products.reduce(0) { $0 + $1.priceInCents }
        let displayAmount = "\(normalizedCurrency) \(formatAmount(totalAmount, decimals: decimals))"
        let shipping = addressSeed(countryCode: merchantProfile.countryCode)

        let items = products.map { product in
            let itemDisplayAmount =
                "\(normalizedCurrency) \(formatAmount(product.priceInCents, decimals: product.fractionDigits))"
            return OrderItem(
                id: product.id,
                name: product.name,
                description: "Product from Explore iOS sample",
                quantity: 1,
                sku: product.id.uppercased(),
                category: "sample",
                totalAmount: AmountPayload(amount: product.priceInCents, displayAmount: itemDisplayAmount),
                unitPrice: AmountPayload(amount: product.priceInCents, displayAmount: itemDisplayAmount)
            )
        }

        let email = "explore-ios+\(UUID().uuidString.prefix(8))@deuna.test"
        let address = OrderAddress(
            firstName: "Explore",
            lastName: "Tester",
            phone: "+593999999999",
            identityDocument: "1234567890",
            lat: shipping.lat,
            lng: shipping.lng,
            address1: "Main Street 123",
            address2: "",
            city: shipping.city,
            zipcode: shipping.zipcode,
            stateName: shipping.stateName,
            country: shipping.countryName,
            countryCode: shipping.countryCode,
            email: email
        )

        let order = OrderData(
            orderId: UUID().uuidString,
            storeCode: "all",
            currency: normalizedCurrency,
            taxAmount: 0,
            shippingAmount: 0,
            itemsTotalAmount: totalAmount,
            subTotal: totalAmount,
            totalAmount: totalAmount,
            displayTotalAmount: displayAmount,
            items: items,
            discounts: [],
            shippingAddress: address,
            billingAddress: address,
            status: "pending",
            timezone: "America/Guayaquil"
        )

        return TokenizeOrderRequest(orderType: "DEUNA_NOW", order: order)
    }

    private func addressSeed(countryCode: String) -> AddressSeed {
        switch countryCode.uppercased() {
        case "MX":
            return AddressSeed(
                city: "Ciudad de Mexico", stateName: "CDMX", countryName: "Mexico", countryCode: "MX",
                zipcode: "06600", lat: 19.4326, lng: -99.1332)
        case "CO":
            return AddressSeed(
                city: "Bogota", stateName: "Cundinamarca", countryName: "Colombia", countryCode: "CO",
                zipcode: "110111", lat: 4.711, lng: -74.0721)
        case "CL":
            return AddressSeed(
                city: "Santiago", stateName: "Region Metropolitana", countryName: "Chile",
                countryCode: "CL", zipcode: "8320000", lat: -33.4489, lng: -70.6693)
        case "PE":
            return AddressSeed(
                city: "Lima", stateName: "Lima", countryName: "Peru", countryCode: "PE", zipcode: "15001",
                lat: -12.0464, lng: -77.0428)
        case "EC":
            return AddressSeed(
                city: "Quito", stateName: "Pichincha", countryName: "Ecuador", countryCode: "EC",
                zipcode: "170150", lat: -0.1807, lng: -78.4678)
        default:
            return AddressSeed(
                city: "Miami", stateName: "Florida", countryName: "United States", countryCode: "US",
                zipcode: "33101", lat: 25.7617, lng: -80.1918)
        }
    }

    private func apiMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return (json["message"] as? String) ?? (json["error"] as? String)
    }

    private func currencyUsesZeroDecimals(_ currencyCode: String) -> Bool {
        currencyCode == "COP" || currencyCode == "CLP"
    }

    private func formatAmount(_ cents: Int, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals

        let divisor = decimals == 0 ? 1.0 : 100.0
        let value = Double(cents) / divisor
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}
