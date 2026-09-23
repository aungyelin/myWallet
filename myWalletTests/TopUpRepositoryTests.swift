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
            _ = try await repository.getPackages(for: "U9")
        }
    }

    @Test("TopUpRepository only handles recharge submission")
    func rechargeSubmissionReturnsResponse() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext
        let repository = TopUpRepository(networkService: MockNetworkService(latencyNanoseconds: 0), modelContext: context)

        let response = try await repository.performRecharge(
            phone: "09250000000",
            operatorName: "MPT",
            planTitle: "1,000 Ks Top-Up",
            amount: 1000.0
        )

        #expect(response.mobileNumber == "09250000000")
        #expect(response.operatorName == "MPT")
        #expect(response.amount == 1000.0)
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

    @Test("getCachedPackages returns locally stored packages for operator")
    func getCachedPackagesSuccess() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext
        let repository = TopUpRepository(
            networkService: MockNetworkService(latencyNanoseconds: 0),
            modelContext: context
        )

        let package = PackageEntity(
            id: "cached_test_1",
            operatorName: "MPT",
            category: "Data",
            packGroup: "A Kyite Kyi",
            name: "Combo 1000MB",
            packageDescription: "Test",
            amount: 998,
            validityDays: 7,
            validityText: "7 Days"
        )
        context.insert(package)
        try context.save()

        let cached = try repository.getCachedPackages(for: "MPT")
        #expect(cached.count == 1)
        #expect(cached.first?.id == "cached_test_1")
    }

    @Test("performRecharge submits to network without persisting transactions")
    func performRechargeReturnsResponse() async throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext
        let repository = TopUpRepository(
            networkService: MockNetworkService(latencyNanoseconds: 0),
            modelContext: context
        )

        let response = try await repository.performRecharge(
            phone: "09253366392",
            operatorName: "MPT",
            planTitle: "1,000 Ks Top-Up",
            amount: 1000
        )

        #expect(response.mobileNumber == "09253366392")
        #expect(response.operatorName == "MPT")
        #expect(response.amount == 1000)
        #expect(!response.referenceNumber.hasPrefix("TXN"))
        #expect(response.referenceNumber.contains("-"))

        let count = try context.fetchCount(FetchDescriptor<TransactionHistory>())
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

    func submitTopUpRecharge(
        phone: String,
        operatorName: String,
        planTitle: String,
        amount: Double
    ) async throws -> TopUpRechargeResponseDTO {
        throw AppError.networkFailure
    }
    
}
