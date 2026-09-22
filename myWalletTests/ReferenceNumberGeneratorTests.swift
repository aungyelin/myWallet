//
//  ReferenceNumberGeneratorTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("ReferenceNumberGenerator Tests")
struct ReferenceNumberGeneratorTests {
    
    @Test("Generates reference with correct YYYYMMDD-XXXXXX format without TXN prefix")
    func validFormat() {
        let reference = ReferenceNumberGenerator.generate()
        #expect(!reference.hasPrefix("TXN"))
        
        let components = reference.split(separator: "-")
        #expect(components.count == 2)
        #expect(components[0].count == 8) // YYYYMMDD
        #expect(components[1].count == 6) // 6 digits
        #expect(Int(components[1]) != nil)
    }

    @Test("Generates distinct numbers on successive calls")
    func uniqueness() {
        let ref1 = ReferenceNumberGenerator.generate()
        let ref2 = ReferenceNumberGenerator.generate()
        #expect(ref1 != ref2)
    }

    @Test("Uses provided date in the formatted reference")
    func customDate() {
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 22
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!

        let reference = ReferenceNumberGenerator.generate(date: date)
        #expect(reference.contains("20260922"))
    }
}
