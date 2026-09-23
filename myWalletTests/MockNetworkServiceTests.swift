//
//  MockNetworkServiceTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("MockNetworkService Tests")
struct MockNetworkServiceTests {
    private let service = MockNetworkService(latencyNanoseconds: 0)

    @Test("Fetch telecom prefixes successfully parses all operators")
    func fetchTelecomPrefixesSuccess() async throws {
        let prefixes = try await service.fetchTelecomPrefixes()
        #expect(!prefixes.isEmpty)
        #expect(prefixes.contains(where: { $0.operatorName == "MPT" && $0.prefix == "0925" }))
        #expect(prefixes.contains(where: { $0.operatorName == "ATOM" && $0.prefix == "0974" }))
        #expect(prefixes.contains(where: { $0.operatorName == "U9" && $0.prefix == "0994" }))
        #expect(prefixes.contains(where: { $0.operatorName == "Mytel" && $0.prefix == "0966" }))
    }

    @Test("Fetch packages successfully returns operator packages")
    func fetchPackagesSuccess() async throws {
        let packages = try await service.fetchPackages()
        #expect(!packages.isEmpty)
        #expect(packages.contains(where: { $0.category == "Data" }))
        #expect(packages.contains(where: { $0.operatorName == "MPT" }))
        #expect(packages.contains(where: { $0.operatorName == "ATOM" }))
        #expect(packages.contains(where: { !$0.packGroup.isEmpty }))
    }

    @Test("submitTopUpRecharge successfully returns server response with reference number")
    func submitTopUpRechargeSuccess() async throws {
        let response = try await service.submitTopUpRecharge(
            phone: "09253366392",
            operatorName: "MPT",
            planTitle: "1,000 Ks Top-Up",
            amount: 1000
        )
        #expect(response.status == Constants.Transaction.statusSuccess)
        #expect(!response.referenceNumber.hasPrefix("TXN"))
        #expect(response.referenceNumber.contains("-"))
        #expect(response.mobileNumber == "09253366392")
        #expect(response.amount == 1000)
    }

    @Test("Fetch seed transactions parses multiple transaction types")
    func fetchSeedTransactionsSuccess() async throws {
        let transactions = try await service.fetchSeedTransactions()
        #expect(!transactions.isEmpty)
        #expect(transactions.contains(where: { $0.transactionType == "top_up" }))
        #expect(transactions.contains(where: { $0.transactionType == "transfer" }))
        #expect(transactions.contains(where: { $0.transactionType == "payment" }))
    }

    @Test("Throws fileNotFound error for nonexistent resource")
    func missingResourceThrowsError() async {
        let emptyBundle = Bundle()
        let invalidService = MockNetworkService(bundle: emptyBundle, latencyNanoseconds: 0)

        await #expect(throws: AppError.self) {
            _ = try await invalidService.fetchTelecomPrefixes()
        }
    }

    @Test("Cancelling an active network fetch throws CancellationError directly")
    func cancellationThrowsCancellationError() async {
        let serviceWithLatency = MockNetworkService(latencyNanoseconds: 1_000_000_000)
        let task = Task {
            try await serviceWithLatency.fetchPackages()
        }
        task.cancel()

        do {
            _ = try await task.value
            Issue.record("Expected CancellationError was not thrown")
        } catch is CancellationError {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}
