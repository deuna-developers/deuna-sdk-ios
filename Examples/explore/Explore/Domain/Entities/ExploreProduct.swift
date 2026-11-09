import Foundation

/// Lightweight merchant profile subset used by the sample app for product/currency rendering.
struct ExploreMerchantProfile {
    let name: String
    let countryCode: String
    let currencyCode: String
}

/// Product displayed by the Explore sample and used to build tokenize-order payloads.
struct ExploreProduct: Identifiable {
    let id: String
    let name: String
    let image: String
    let priceInCents: Int
    let fractionDigits: Int
    let currencyCode: String
    let currencySymbol: String
}
