//
//  MockTelecomRepository.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
@testable import myWallet

@MainActor
final class MockTelecomRepository: TelecomRepositoryProtocol {
    var detectedPrefixToReturn: TelecomPrefixEntity?
    var prefixesToReturn: [TelecomPrefixEntity] = []
    var detectOperatorCallCount = 0
    var detectedNumbers: [String] = []
    var prefetchCallCount = 0

    func detectOperator(for rawPhoneNumber: String) async throws -> TelecomPrefixEntity? {
        detectOperatorCallCount += 1
        detectedNumbers.append(rawPhoneNumber)
        return detectedPrefixToReturn
    }

    func getPrefixes() async throws -> [TelecomPrefixEntity] {
        return prefixesToReturn
    }

    func prefetchPrefixes() async {
        prefetchCallCount += 1
    }

    func sanitizeAndNormalize(_ input: String) -> String {
        guard !input.isEmpty else { return "" }

        // Convert Myanmar numerals (၀-၉) to Arabic (0-9)
        var convertedString = ""
        let myanmarZeroScalar: UInt32 = 0x1040
        for char in input {
            if let scalar = char.unicodeScalars.first, scalar.value >= 0x1040 && scalar.value <= 0x1049 {
                let arabicDigit = scalar.value - myanmarZeroScalar
                convertedString.append(String(arabicDigit))
            } else {
                convertedString.append(char)
            }
        }

        let trimmed = convertedString.trimmingCharacters(in: .whitespacesAndNewlines)
        let digitsOnly = trimmed.filter { $0.isNumber }

        var standardized: String
        if digitsOnly.hasPrefix("959") {
            standardized = "09" + digitsOnly.dropFirst(3)
        } else if digitsOnly.hasPrefix("9") && digitsOnly.count >= 8 {
            standardized = "0" + digitsOnly
        } else {
            standardized = digitsOnly
        }

        if standardized.count > 11 {
            return String(standardized.prefix(11))
        }

        return standardized
    }
}
