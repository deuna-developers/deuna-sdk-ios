//
//  PaymentSuccessView.swift
//  basic-integration
//
//  Created by deuna on 9/7/24.
//

import DeunaSDK
import Foundation
import SwiftUI

struct OrderItem: Identifiable {
    let id: String
    let name: String
    let options: String?
    let totalAmount: String

    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let totalAmountDict = dictionary["total_amount"] as? [String: Any],
              let totalAmount = totalAmountDict["display_amount"] as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.options = dictionary["options"] as? String
        self.totalAmount = totalAmount
    }
}

public struct PaymentSuccessView: View {
    public let order: [String: Any]
    public let onBack: () -> Void
    
    private var items: [OrderItem] {
        if let itemsArray = order["items"] as? [[String: Any]] {
            return itemsArray.compactMap { OrderItem(dictionary: $0) }
        }
        return []
    }

    public var body: some View {

        VStack(spacing: 20) {
            Text("Payment Successful")
            Spacer()
            HStack{
                Text("ORDER ID: \(order["order_id"]!)")
            }
            List(items, id: \.id) { item in
                VStack(alignment: .leading) {
                    Text(item.name)
                    Text(item.options ?? "")
                    HStack {
                        Text("TOTAL:")
                        Text(item.totalAmount)
                    }
                }
            }
            Button(
                action: onBack
            ) {
                Text("Go back").frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)

        }.padding()
    }
}

private func getMock() -> [String: Any]? {
    let jsonString = """
    {
        "currency": "USD",
        "discounts": [{
            "amount": 10,
            "code": "SUMMER10",
            "description": "Summer Sale Discount",
            "details_url": "https://example.com/discount-details",
            "discount_category": "Seasonal",
            "display_amount": "$10.00",
            "free_shipping": {
                "is_free_shipping": true,
                "maximum_cost_allowed": 20
            },
            "reference": "REF12345",
            "target_type": "Order",
            "type": "Percentage"
        }],
        "items": [{
            "brand": "ExampleBrand",
            "category": "Clothing",
            "color": "Red",
            "description": "A stylish red shirt",
            "details_url": "https://example.com/item-details",
            "id": "ITEM123",
            "image_url": "https://example.com/image.png",
            "item_details": [{
                "priority": 1,
                "label": "Size",
                "value": "M"
            }, {
                "priority": 2,
                "label": "Material",
                "value": "Cotton"
            }],
            "manufacturer": "ExampleManufacturer",
            "name": "Red Shirt",
            "options": "Size: M, Color: Red",
            "quantity": 2,
            "size": "M",
            "sku": "SKU123",
            "subscription_id": "SUB123",
            "tax_amount": {
                "amount": 5,
                "currency": "USD",
                "currency_symbol": "$",
                "display_amount": "$5.00"
            },
            "taxable": true,
            "total_amount": {
                "amount": 50,
                "currency": "USD",
                "currency_symbol": "$",
                "display_amount": "$50.00",
                "display_original_amount": "$55.00",
                "display_total_discount": "$5.00",
                "original_amount": 55,
                "total_discount": 5
            },
            "type": "Physical",
            "unit_price": {
                "amount": 25,
                "currency": "USD",
                "currency_symbol": "$",
                "display_amount": "$25.00"
            },
            "weight": {
                "unit": "kg",
                "weight": 1
            }
        }],
        "items_total_amount": 50,
        "order_id": "ORDER12345",
        "payment": {
            "data": {
                "amount": {
                    "amount": 50,
                    "currency": "USD"
                },
                "authorization_code": "AUTH123",
                "created_at": "2023-07-09T12:34:56Z",
                "customer": {
                    "email": "customer@example.com",
                    "first_name": "John",
                    "id": "CUST123",
                    "last_name": "Doe"
                },
                "external_transaction_id": "EXT123",
                "from_card": {
                    "bank_name": "ExampleBank",
                    "card_brand": "Visa",
                    "country_iso": "US",
                    "first_six": "123456",
                    "installment": {
                        "installment_amount": 10,
                        "installment_rate": 5,
                        "installment_type": "Fixed",
                        "installments": 5,
                        "plan_id": "PLAN123",
                        "plan_option_id": "OPTION123"
                    },
                    "last_four": "7890"
                },
                "id": "PAYMENT123",
                "merchant": {
                    "id": "MERCHANT123",
                    "store_code": "STORE123"
                },
                "merchant_payment_processor_name": "ExampleProcessor",
                "method_type": "CreditCard",
                "processor": "ExampleProcessor",
                "reason": "Purchase",
                "status": "Completed",
                "updated_at": "2023-07-09T12:45:00Z"
            }
        },
        "shipping_amount": 5,
        "status": "Pending",
        "sub_total": 55,
        "total_amount": 60,
        "transaction_id": "TRANS123"
    }
    """
    
    do {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return json
    } catch {
        print("\(error.localizedDescription)")
        return nil
    }
}

#Preview {
    PaymentSuccessView(
        order: getMock()!,
        onBack: {}
    )
}
