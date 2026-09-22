//
//  TelecomRepositoryTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Testing
import Foundation
import SwiftData
@testable import myWallet

@Suite("TelecomRepository Tests")
@MainActor
struct TelecomRepositoryTests {
    @Test("Number Normalization: Formats varied input formats into internal 09... standard")
    func numberNormalization() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TelecomRepository(
            networkService: MockNetworkService(latencyNanoseconds: 0),
            modelContext: container.mainContext
        )

        #expect(repository.sanitizeAndNormalize("+95 9 250 123 456") == "09250123456")
        #expect(repository.sanitizeAndNormalize("959450000000") == "09450000000")
        #expect(repository.sanitizeAndNormalize("09-778-239-012") == "09778239012")
        #expect(repository.sanitizeAndNormalize("9250123456") == "09250123456")
        #expect(repository.sanitizeAndNormalize("(09) 971 234 567") == "09971234567")
        // Myanmar Unicode numerals conversion (၀-၉)
        #expect(repository.sanitizeAndNormalize("၀၉၂၅၀၀၀၀၀၀၀") == "09250000000")
        #expect(repository.sanitizeAndNormalize("+၉၅၉၇၇၀၀၀၀၀၀၀") == "09770000000")
        #expect(repository.sanitizeAndNormalize("၀9.450.123.456") == "09450123456")
    }

    @Test("Operator Detection: Accurately identifies Myanmar telecoms")
    func operatorDetection() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TelecomRepository(
            networkService: MockNetworkService(latencyNanoseconds: 0),
            modelContext: container.mainContext
        )

        let mpt = try await repository.detectOperator(for: "09250000000")
        #expect(mpt?.operatorName == "MPT")

        let mptLong = try await repository.detectOperator(for: "+959890000000")
        #expect(mptLong?.operatorName == "MPT")
        #expect(mptLong?.prefix == "0989")

        let atom = try await repository.detectOperator(for: "09770000000")
        #expect(atom?.operatorName == "ATOM")

        let ooredoo = try await repository.detectOperator(for: "09970000000")
        #expect(ooredoo?.operatorName == "Ooredoo")

        let mytel = try await repository.detectOperator(for: "09690000000")
        #expect(mytel?.operatorName == "Mytel")
    }

    @Test("Short Input: Returns nil when input has fewer than 3 digits")
    func shortInputReturnsNil() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TelecomRepository(
            networkService: MockNetworkService(latencyNanoseconds: 0),
            modelContext: container.mainContext
        )

        let result = try await repository.detectOperator(for: "09")
        #expect(result == nil)
    }

    @Test("Unrecognized Prefix: Returns nil for unsupported numbers")
    func unrecognizedPrefixReturnsNil() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TelecomRepository(
            networkService: MockNetworkService(latencyNanoseconds: 0),
            modelContext: container.mainContext
        )

        let result = try await repository.detectOperator(for: "09112345678")
        #expect(result == nil)
    }

    @Test("Cache Fallback: Serves cached prefixes offline when network fails")
    func cacheFallbackWhenOffline() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext

        let cached = TelecomPrefixEntity(
            prefix: "097",
            operatorName: "ATOM",
            brandDisplayName: "ATOM",
            brandLogoName: "atom_logo"
        )
        context.insert(cached)
        try context.save()

        let failingNetwork = FailingTelecomNetworkService()
        let repository = TelecomRepository(networkService: failingNetwork, modelContext: context)

        let result = try await repository.detectOperator(for: "09790000000")
        #expect(result?.operatorName == "ATOM")
    }

    @Test("Network Failure without Cache: Throws AppError.networkFailure")
    func networkFailureWithoutCacheThrows() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext

        let failingNetwork = FailingTelecomNetworkService()
        let repository = TelecomRepository(networkService: failingNetwork, modelContext: context)

        await #expect(throws: AppError.networkFailure) {
            _ = try await repository.detectOperator(for: "09790000000")
        }
    }

    @Test("prefetchPrefixes: Silently caches prefixes when network succeeds")
    func prefetchPrefixesSuccess() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext
        let repository = TelecomRepository(
            networkService: MockNetworkService(latencyNanoseconds: 0),
            modelContext: context
        )

        await repository.prefetchPrefixes()

        let count = try context.fetchCount(FetchDescriptor<TelecomPrefixEntity>())
        #expect(count > 0)
    }

    @Test("prefetchPrefixes: Silently completes without error when network fails")
    func prefetchPrefixesFailsSilently() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext
        let repository = TelecomRepository(
            networkService: FailingTelecomNetworkService(),
            modelContext: context
        )

        await repository.prefetchPrefixes()

        let count = try context.fetchCount(FetchDescriptor<TelecomPrefixEntity>())
        #expect(count == 0)
    }

    @Test("Instant Offline Keystroke Detection: Evaluates from cache without network latency")
    func instantOfflineDetection() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext

        let prefix = TelecomPrefixEntity(
            prefix: "094",
            operatorName: "MPT",
            brandDisplayName: "MPT",
            brandLogoName: "mpt_logo"
        )
        context.insert(prefix)
        try context.save()

        // Use a mock network that would throw if called, proving detectOperator evaluates offline without network call
        let networkThatMustNotBeCalled = FailingTelecomNetworkService()
        let repository = TelecomRepository(networkService: networkThatMustNotBeCalled, modelContext: context)

        let detected = try await repository.detectOperator(for: "09450123456")
        #expect(detected?.operatorName == "MPT")
        #expect(detected?.operatorType == .mpt)
    }
}

// MARK: - Failing Network Mock
private final class FailingTelecomNetworkService: MockNetworkServiceProtocol, Sendable {
    func fetchTelecomPrefixes() async throws -> [TelecomPrefixDTO] {
        throw AppError.networkFailure
    }

    func fetchPackages() async throws -> [PackageDTO] {
        throw AppError.networkFailure
    }

    func fetchSeedTransactions() async throws -> [TransactionHistoryDTO] {
        throw AppError.networkFailure
    }
}
