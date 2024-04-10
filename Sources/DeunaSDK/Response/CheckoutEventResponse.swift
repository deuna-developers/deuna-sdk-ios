
// TODO: This class seems to be not used inside the SDK
struct Data: Codable {
    struct Order: Codable {
        struct Item: Codable {
            struct Amount: Codable {
                var amount: Int
                var original_amount: Int
                var display_amount: String
                var display_original_amount: String
                var currency: String
                var currency_symbol: String
                var display_total_discount: String
                var total_discount: Int
            }
            
            struct Weight: Codable {
                var weight: Int
                var unit: String
            }
            
            var id: String
            var name: String
            var description: String
            var options: String
            var total_amount: Amount?
            var unit_price: Amount?
            var tax_amount: Amount?
            var quantity: Int
            var uom: String
            var upc: String
            var sku: String
            var isbn: String
            var brand: String
            var manufacturer: String
            var category: String
            var color: String
            var size: String
            var weight: Weight
            var image_url: String
            var details_url: String
            var type: String
            var taxable: Bool
//            var discounts: [Any] = []
            var included_in_subscription: Bool
            var subscription_id: String
        }
        
        struct Payment: Codable {
            struct PaymentData: Codable {
                struct PaymentAmount: Codable {
                    var amount: Int
                    var currency: String
                }

                struct FromCard: Codable {
                    var card_brand: String
                    var first_six: String
                    var last_four: String
                    var bank_name: String
                    var country_iso: String
                }

                struct Merchant: Codable {
                    var store_code: String
                    var id: String
                }

                struct Customer: Codable {
                    var email: String
                    var id: String
                    var first_name: String
                    var last_name: String
                }

                var amount: PaymentAmount
//                var metadata: Any = Any
                var from_card: FromCard
                var updated_at: String
                var method_type: String
                var merchant: Merchant
                var created_at: String
                var id: String
                var processor: String
                var customer: Customer
                var status: String
                var reason: String
                var external_transaction_id: String
            }
        
            var data: PaymentData
        }
        
        var order_id: String
        var currency: String
        var tax_amount: Double
        var items_total_amount: Int
        var sub_total: Double
        var total_amount: Int
        var items: [Item]
//        var discounts: [Any] = []
//        var metadata: [String: Any] = [String: Any]()
        var status: String
        var payment: Payment
        var transaction_id: String
    }
    
    struct Merchant: Codable {
        var id: String
        var name: String
        var code: String
        var country: String
    }

    struct SchemaRegistry: Codable {
        var source: String
        var schemaId: String
        var schema: String
        var registryName: String
    }
    
    struct User: Codable {
        var id: String
        var email: String
        var is_guest: Bool
    }
    
    var order: Order
    var user: User
    var merchant: Merchant
    var checkoutVersion: String
    var schemaRegistry: SchemaRegistry
}
