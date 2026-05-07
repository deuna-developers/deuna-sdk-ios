import Foundation

/// Builds a small product catalog similar to Explore Web and adapts prices by currency.
enum ProductCatalog {
    private struct CurrencyProfile {
        let code: String
        let symbol: String
        let rateFromUSD: Double
        let decimalDigits: Int
    }

    private struct ProductSeed {
        let id: String
        let name: String
        let image: String
        let baseUSDPrice: Double
    }

    private static let seeds: [ProductSeed] = [
        .init(id: "polo-shirt", name: "Polo Shirt", image: "tshirt", baseUSDPrice: 105.55),
        .init(id: "headphones", name: "Headphones", image: "headphones", baseUSDPrice: 151.00),
        .init(id: "sun-glasses", name: "Sun Glasses", image: "sunglasses", baseUSDPrice: 50.00),
    ]

    private static let fallbackCurrency = CurrencyProfile(
        code: "USD", symbol: "$", rateFromUSD: 1, decimalDigits: 2)

    private static let currencyProfiles: [String: CurrencyProfile] = [
        "USD": .init(code: "USD", symbol: "$", rateFromUSD: 1, decimalDigits: 2),
        "MXN": .init(code: "MXN", symbol: "$", rateFromUSD: 17.0, decimalDigits: 2),
        "COP": .init(code: "COP", symbol: "$", rateFromUSD: 3900, decimalDigits: 0),
        "CLP": .init(code: "CLP", symbol: "$", rateFromUSD: 950, decimalDigits: 0),
        "PEN": .init(code: "PEN", symbol: "S/", rateFromUSD: 3.75, decimalDigits: 2),
        "BRL": .init(code: "BRL", symbol: "R$", rateFromUSD: 5.1, decimalDigits: 2),
    ]

    static func buildProducts(currencyCode: String) -> [ExploreProduct] {
        let profile = currencyProfiles[currencyCode.uppercased()] ?? fallbackCurrency

        return seeds.map { seed in
            let convertedValue = seed.baseUSDPrice * profile.rateFromUSD
            let centsMultiplier = profile.decimalDigits == 0 ? 1 : 100
            let cents = Int((convertedValue * Double(centsMultiplier)).rounded())
            return ExploreProduct(
                id: seed.id,
                name: seed.name,
                image: seed.image,
                priceInCents: cents,
                fractionDigits: profile.decimalDigits,
                currencyCode: profile.code,
                currencySymbol: profile.symbol
            )
        }
    }

    static func formatPrice(cents: Int, fractionDigits: Int, currencySymbol: String) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.numberStyle = .decimal

        let divisor = fractionDigits == 0 ? 1.0 : 100.0
        let value = Double(cents) / divisor
        let amountText = formatter.string(from: NSNumber(value: value)) ?? String(value)
        return "\(currencySymbol) \(amountText)"
    }

    static func fallbackMerchantProfile() -> ExploreMerchantProfile {
        ExploreMerchantProfile(name: "", countryCode: "US", currencyCode: "USD")
    }
}

typealias ExploreProductCatalog = ProductCatalog

/// Repository adapter that exposes catalog operations through `Domain` contracts.
struct ProductsRepositoryImpl: ProductsRepository {
    func buildProducts(currencyCode: String) -> [ExploreProduct] {
        ProductCatalog.buildProducts(currencyCode: currencyCode)
    }

    func formatPrice(cents: Int, fractionDigits: Int, currencySymbol: String) -> String {
        ProductCatalog.formatPrice(
            cents: cents,
            fractionDigits: fractionDigits,
            currencySymbol: currencySymbol
        )
    }
}
