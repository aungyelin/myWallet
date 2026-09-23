//
//  CurrencyFormatterTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("CurrencyFormatter Tests")
struct CurrencyFormatterTests {
    
    @Test("CurrencyFormatter formats standard wallet balances with Ks suffix")
    func formatStandardAmount() {
        let result = CurrencyFormatter.format(1_250_000)
        #expect(result == "1,250,000 Ks")
    }
    
    @Test("CurrencyFormatter formats zero balance correctly")
    func formatZero() {
        let result = CurrencyFormatter.format(0)
        #expect(result == "0 Ks")
    }
    
    @Test("CurrencyFormatter formats top-up denominations with grouping separators")
    func formatDenominations() {
        #expect(CurrencyFormatter.format(1_000) == "1,000 Ks")
        #expect(CurrencyFormatter.format(3_000) == "3,000 Ks")
        #expect(CurrencyFormatter.format(5_000) == "5,000 Ks")
        #expect(CurrencyFormatter.format(10_000) == "10,000 Ks")
        #expect(CurrencyFormatter.format(50_000) == "50,000 Ks")
    }
    
    @Test("CurrencyFormatter supports custom currency suffixes")
    func formatCustomCurrency() {
        let result = CurrencyFormatter.format(10_000, currency: "MMK")
        #expect(result == "10,000 MMK")
    }
    
    @Test("CurrencyFormatter formats amount only without currency suffix")
    func formatAmountOnly() {
        let result = CurrencyFormatter.formatAmountOnly(1_250_000)
        #expect(result == "1,250,000")
    }
    
    @Test("Double convenience extensions provide identical formatting")
    func doubleConvenienceExtensions() {
        let amount: Double = 25_000
        #expect(amount.formattedCurrency == "25,000 Ks")
        #expect(amount.formattedAmountOnly == "25,000")
    }
}
