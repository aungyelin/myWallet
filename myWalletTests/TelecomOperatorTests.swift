//
//  TelecomOperatorTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("TelecomOperator Tests")
struct TelecomOperatorTests {
    
    @Test("Raw values map to expected uppercase operator codes")
    func rawValues() {
        #expect(TelecomOperator.mpt.rawValue == "MPT")
        #expect(TelecomOperator.atom.rawValue == "ATOM")
        #expect(TelecomOperator.ooredoo.rawValue == "Ooredoo")
        #expect(TelecomOperator.mytel.rawValue == "Mytel")
        #expect(TelecomOperator.unknown.rawValue == "Unknown")
    }

    @Test("Resolves operator from raw string case-insensitively")
    func resolutionFromRawString() {
        #expect(TelecomOperator.from(rawName: "mpt") == .mpt)
        #expect(TelecomOperator.from(rawName: "MPT") == .mpt)
        #expect(TelecomOperator.from(rawName: "atom") == .atom)
        #expect(TelecomOperator.from(rawName: "ATOM") == .atom)
        #expect(TelecomOperator.from(rawName: "ooredoo") == .ooredoo)
        #expect(TelecomOperator.from(rawName: "mytel") == .mytel)
        #expect(TelecomOperator.from(rawName: "invalid") == .unknown)
        #expect(TelecomOperator.from(rawName: nil) == .unknown)
        #expect(TelecomOperator.from(rawName: "") == .unknown)
    }

    @Test("Exposes non-empty display names, brand assets, and semantic colors")
    func brandProperties() {
        for op in TelecomOperator.allCases {
            #expect(!op.displayName.isEmpty)
            #expect(!op.brandColorToken.isEmpty)
            #expect(!op.logoImageName.isEmpty)
            #expect(op.brandColor != nil)
        }
    }

    @Test("TransactionStatus exposes localized title, semantic color, and icon")
    func transactionStatusProperties() {
        for status in TransactionStatus.allCases {
            #expect(!status.localizedTitle.isEmpty)
            #expect(!status.systemIconName.isEmpty)
            #expect(status.statusColor != nil)
        }
    }
}
