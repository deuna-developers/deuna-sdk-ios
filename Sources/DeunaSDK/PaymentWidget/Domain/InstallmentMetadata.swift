//
//  InstallmentMetadata.swift
//
//  Created by deuna on 28/6/24.
//

import Foundation

public struct InstallmentMetadata: Codable {
    public let card_bin: String
    public let plan_option_id: String
    public let display_installment_label: String
    public let display_installments_amount: String
    public let installments: Int
    public let installment_rate: Int
}
