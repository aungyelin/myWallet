//
//  AppErrorTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("AppError Localization & Equality Tests")
struct AppErrorTests {
    @Test("All AppError cases produce non-empty errorDescription and recoverySuggestion")
    func errorDescriptionsAndSuggestions() {
        let errors: [AppError] = [
            .invalidPhoneNumber,
            .unrecognizedOperator,
            .packageNotFound,
            .networkFailure,
            .decodingFailure("Corrupted payload"),
            .persistenceFailure("Disk full"),
            .fileNotFound("sample.json"),
            .unknown("Unexpected error")
        ]

        for error in errors {
            let description = error.errorDescription
            let suggestion = error.recoverySuggestion

            #expect(description != nil)
            #expect(!(description?.isEmpty ?? true))
            #expect(suggestion != nil)
            #expect(!(suggestion?.isEmpty ?? true))
        }
    }

    @Test("AppError equality checks operate correctly")
    func appErrorEquality() {
        #expect(AppError.invalidPhoneNumber == AppError.invalidPhoneNumber)
        #expect(AppError.unrecognizedOperator == AppError.unrecognizedOperator)
        #expect(AppError.decodingFailure("test") == AppError.decodingFailure("test"))
        #expect(AppError.decodingFailure("test1") != AppError.decodingFailure("test2"))
        #expect(AppError.networkFailure != AppError.packageNotFound)
    }
}
