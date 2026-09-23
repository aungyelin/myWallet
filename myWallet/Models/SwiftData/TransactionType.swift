//
//  TransactionType.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation

public enum TransactionType: String, Codable, CaseIterable, Sendable {
    case topUp = "top_up"
    case transfer = "transfer"
    case payment = "payment"

    public var localizedTitle: String {
        switch self {
        case .topUp:
            return String(localized: "transaction_type_top_up", defaultValue: "Mobile Top-Up")
        case .transfer:
            return String(localized: "transaction_type_transfer", defaultValue: "Transfer")
        case .payment:
            return String(localized: "transaction_type_payment", defaultValue: "Payment")
        }
    }

    public var systemIconName: String {
        switch self {
        case .topUp:
            return "iphone.gen3"
        case .transfer:
            return "arrow.left.arrow.right"
        case .payment:
            return "creditcard"
        }
    }
}
