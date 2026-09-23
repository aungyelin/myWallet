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

        // Detection is intentionally offline; seed the local catalog first.
        _ = try await repository.getPrefixes()

        let mpt = try await repository.detectOperator(for: "09250000000")
        #expect(mpt?.operatorName == "MPT")

        let mptLong = try await repository.detectOperator(for: "+959890000000")
        #expect(mptLong?.operatorName == "MPT")
        #expect(mptLong?.prefix == "0989")

        let atom = try await repository.detectOperator(for: "09770000000")
        #expect(atom?.operatorName == "ATOM")

        let atom979 = try await repository.detectOperator(for: "09790000000")
        #expect(atom979?.operatorName == "ATOM")

        let u9 = try await repository.detectOperator(for: "09970000000")
        #expect(u9?.operatorName == "U9")
        #expect(u9?.operatorType == .u9)

        let mytel = try await repository.detectOperator(for: "09690000000")
        #expect(mytel?.operatorName == "Mytel")
    }

    @Test("Operator Detection: Covers the documented Myanmar operator ranges")
    func documentedOperatorRanges() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TelecomRepository(
            networkService: MockNetworkService(latencyNanoseconds: 0),
            modelContext: container.mainContext
        )

        // Detection is intentionally offline; seed the local catalog first.
        _ = try await repository.getPrefixes()

        let expectedOperators: [(String, TelecomOperator)] = [
            ("09200000000", .mpt), ("09210000000", .mpt), ("09260000000", .mpt),
            ("09400000000", .mpt), ("09410000000", .mpt), ("09420000000", .mpt),
            ("09500000000", .mpt), ("09510000000", .mpt),
            ("09880000000", .mpt),
            ("09740000000", .atom), ("09750000000", .atom), ("09760000000", .atom),
            ("09770000000", .atom), ("09780000000", .atom), ("09790000000", .atom),
            ("09940000000", .u9), ("09950000000", .u9), ("09960000000", .u9),
            ("09970000000", .u9), ("09980000000", .u9),
            ("09660000000", .mytel), ("09670000000", .mytel),
            ("09680000000", .mytel), ("09690000000", .mytel)
        ]

        for (number, expectedOperator) in expectedOperators {
            let detected = try await repository.detectOperator(for: number)
            #expect(detected?.operatorType == expectedOperator, Comment(rawValue: number))
        }
    }

    @Test("Prefix catalog contains only four-digit prefixes")
    func prefixCatalogUsesFourDigits() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TelecomRepository(
            networkService: MockNetworkService(latencyNanoseconds: 0),
            modelContext: container.mainContext
        )

        let prefixes = try await repository.getPrefixes()
        #expect(!prefixes.isEmpty)
        #expect(prefixes.allSatisfy { $0.prefix.count == 4 })
        let removedLegacyPrefix = try await repository.detectOperator(for: "09900000000")
        #expect(removedLegacyPrefix == nil)
    }

    @Test("Short Input: Returns nil when input has fewer than 4 digits")
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
            prefix: "0979",
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

    @Test("Network Failure without Cache: Offline detection returns nil")
    func networkFailureWithoutCacheReturnsNil() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext

        let failingNetwork = FailingTelecomNetworkService()
        let repository = TelecomRepository(networkService: failingNetwork, modelContext: context)

        let result = try await repository.detectOperator(for: "09790000000")
        #expect(result == nil)
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
            prefix: "0940",
            operatorName: "MPT",
            brandDisplayName: "MPT",
            brandLogoName: "mpt_logo"
        )
        context.insert(prefix)
        try context.save()

        // Use a mock network that would throw if called, proving detectOperator evaluates offline without network call
        let networkThatMustNotBeCalled = FailingTelecomNetworkService()
        let repository = TelecomRepository(networkService: networkThatMustNotBeCalled, modelContext: context)

        let detected = try await repository.detectOperator(for: "09401234567")
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

    func submitTopUpRecharge(
        phone: String,
        operatorName: String,
        planTitle: String,
        amount: Double
    ) async throws -> TopUpRechargeResponseDTO {
        throw AppError.networkFailure
    }
}
