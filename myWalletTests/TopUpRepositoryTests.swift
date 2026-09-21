//
//  TopUpRepositoryTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Testing
import Foundation
import SwiftData
@testable import myWallet

@Suite("TopUpRepository Tests")
@MainActor
struct TopUpRepositoryTests {
    @Test("Network-First: Successfully fetches, persists, and returns packages")
    func networkFirstSuccess() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext
        let networkService = MockNetworkService(latencyNanoseconds: 0)
        let repository = TopUpRepository(networkService: networkService, modelContext: context)

        let packages = try await repository.getPackages(for: "MPT")
        #expect(!packages.isEmpty)
        #expect(packages.allSatisfy { $0.operatorName == "MPT" })

        // Verify data was persisted to SwiftData
        let countInDb = try context.fetchCount(FetchDescriptor<PackageEntity>())
        #expect(countInDb > 0)
    }

    @Test("Cache Fallback: Serves cached packages silently when network fails")
    func networkFailureWithCacheServesOffline() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext

        // Pre-populate SwiftData cache with an offline package
        let cachedPackage = PackageEntity(
            id: "cached_pkg_1",
            operatorName: "ATOM",
            category: "denomination",
            name: "1,000 Ks",
            packageDescription: "Offline test",
            amount: 1000.0,
            validityDays: 0,
            validityText: "No Expiry"
        )
        context.insert(cachedPackage)
        try context.save()

        // Create repository with failing network
        let failingNetwork = TestFailingNetworkService()
        let repository = TopUpRepository(networkService: failingNetwork, modelContext: context)

        // Must succeed using cache without throwing error
        let packages = try await repository.getPackages(for: "ATOM")
        #expect(packages.count == 1)
        #expect(packages.first?.id == "cached_pkg_1")
    }

    @Test("Network Failure without Cache: Throws AppError.networkFailure")
    func networkFailureWithoutCacheThrows() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext

        let failingNetwork = TestFailingNetworkService()
        let repository = TopUpRepository(networkService: failingNetwork, modelContext: context)

        await #expect(throws: AppError.networkFailure) {
            _ = try await repository.getPackages(for: "Ooredoo")
        }
    }

    @Test("saveTransaction persists transaction record into SwiftData")
    func saveTransactionSuccess() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext
        let repository = TopUpRepository(networkService: MockNetworkService(latencyNanoseconds: 0), modelContext: context)

        let transaction = TransactionHistory.createTopUp(
            mobileNumber: "09250000000",
            operatorName: "MPT",
            planDetails: "1,000 Ks Top-Up",
            amount: 1000.0
        )

        try repository.saveTransaction(transaction)

        let fetched = try context.fetch(FetchDescriptor<TransactionHistory>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.mobileNumber == "09250000000")
        #expect(fetched.first?.operatorName == "MPT")
    }

    @Test("prefetchPackages: Silently caches data when network succeeds")
    func prefetchPackagesSuccess() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext
        let repository = TopUpRepository(
            networkService: MockNetworkService(latencyNanoseconds: 0),
            modelContext: context
        )

        await repository.prefetchPackages()

        let count = try context.fetchCount(FetchDescriptor<PackageEntity>())
        #expect(count > 0)
    }

    @Test("prefetchPackages: Silently completes without error when network fails")
    func prefetchPackagesFailsSilently() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext
        let repository = TopUpRepository(
            networkService: TestFailingNetworkService(),
            modelContext: context
        )

        await repository.prefetchPackages()

        let count = try context.fetchCount(FetchDescriptor<PackageEntity>())
        #expect(count == 0)
    }
}

// MARK: - Test Mock Helper
private final class TestFailingNetworkService: MockNetworkServiceProtocol, Sendable {
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
