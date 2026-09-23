//
//  CurrencyFormatter.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation

public enum CurrencyFormatter {
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter
    }()
    
    public static func format(
        _ amount: Double,
        currency: String = AppLocalization.string("home_balance_currency", defaultValue: "Ks")
    ) -> String {
        let formattedNumber = formatAmountOnly(amount)
        return "\(formattedNumber) \(currency)"
    }
    
    public static func formatAmountOnly(_ amount: Double) -> String {
        numberFormatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }
    
}

// MARK: - Double Convenience Extension

extension Double {
    /// Formats the receiver as localized currency string (e.g., `1250000.formattedCurrency` -> `"1,250,000 Ks"`).
    public var formattedCurrency: String {
        CurrencyFormatter.format(self)
    }
    
    /// Formats the receiver with grouping separators only (e.g., `1250000.formattedAmountOnly` -> `"1,250,000"`).
    public var formattedAmountOnly: String {
        CurrencyFormatter.formatAmountOnly(self)
    }
}
