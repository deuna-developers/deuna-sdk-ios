//
//  RefetchOrder.swift
//
//
//  Created by deuna on 27/6/24.
//

import Foundation


public struct RefetchedOrder: Codable {
    let order_id: String
    let transaction_id: String?
    let store_code: String?
    let currency: String
    let tax_amount: Int
    let display_tax_amount: String
    let shipping_amount: Int
    let display_shipping_amount: String
    let items_total_amount: Int
    let display_items_total_amount: String
    let sub_total: Int
    let display_sub_total: String
    let total_amount: Int
    let display_total_amount: String
    let items: [Item]
    let discounts: [Discount]?
    let shipping_address: Address?
    let status: String
    let total_discount: Int
    let display_total_discount: String
    let billing_address: Address?
    let display_shipping_tax_amount: String
    let display_total_tax_amount: String
    let shipping_tax_amount: Int
    let total_tax_amount: Int
    let discount_amount: Int
    let shipping_discount_amount: Int
    let total_interest_amount: Int
    let display_total_interest_amount: String

    struct Item: Codable {
        let id: String
        let name: String
        let description: String
        let options: String?
        let total_amount: Amount
        let unit_price: Amount
        let tax_amount: Amount
    }

    struct Amount: Codable {
        let amount: Int
        let original_amount: Int?
        let display_amount: String
        let display_original_amount: String?
        let currency: String
        let currency_symbol: String
        let discount_amount: Int?
    }

    struct Weight: Codable {
        let weight: Int
        let unit: String
    }
    
    struct Discount: Codable {
        let amount: Int
        let display_amount: String
        let code: String
        let description: String?
    }

    struct Address: Codable {
        let id: Int
        let user_id: String
        let first_name: String
        let last_name: String
        let phone: String
        let identity_document: String
        let lat: Double
        let lng: Double
        let address1: String
        let address2: String
        let city: String
        let zipcode: String
        let state_name: String
        let country_code: String
        let additional_description: String
        let address_type: String
        let is_default: Bool
        let email: String?
        let identity_document_type: String
    }
}
