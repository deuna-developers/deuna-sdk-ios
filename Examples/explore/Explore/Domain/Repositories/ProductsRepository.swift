import Foundation

/// Contract for product catalog and price formatting in the sample app.
protocol ProductsRepository {
    func buildProducts(currencyCode: String) -> [ExploreProduct]
    func formatPrice(cents: Int, fractionDigits: Int, currencySymbol: String) -> String
}
