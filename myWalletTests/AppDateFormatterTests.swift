//
//  AppDateFormatterTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("AppDateFormatter Tests")
struct AppDateFormatterTests {

    @Test("formatReceiptDate formats with international Gregorian calendar year")
    func receiptDateFormatting() {
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 23
        components.hour = 14
        components.minute = 30
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!

        let formatted = AppDateFormatter.formatReceiptDate(date)

        // Must display international year 2026, never local calendar years (such as 2569 BE)
        #expect(formatted.contains("2026"))
        #expect(!formatted.contains("2569"))
        #expect(formatted.contains("Sep"))
        #expect(formatted.contains("23"))
    }

    @Test("Custom format style uses international Gregorian calendar")
    func customFormatStyle() {
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 15
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!

        let formatted = AppDateFormatter.format(date, dateStyle: .medium, timeStyle: .none)
        #expect(formatted.contains("2026"))
        #expect(!formatted.contains("2569"))
    }
}
