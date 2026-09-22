//
//  MockTopUpRepository.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
@testable import myWallet

@MainActor
final class MockTopUpRepository: TopUpRepositoryProtocol {
    var packagesToReturn: [PackageEntity] = []
    var cachedPackagesToReturn: [PackageEntity] = []
    var prefetchCallCount = 0
    var savedTransactions: [TransactionHistory] = []
    var transactionToReturnOnRecharge: TransactionHistory?
    var shouldFailRecharge = false
    var shouldFailGetPackages = false

    func getPackages(for operatorName: String) async throws -> [PackageEntity] {
        if shouldFailGetPackages {
            throw AppError.networkFailure
        }
        return packagesToReturn.filter { $0.operatorName == operatorName }
    }

    func getCachedPackages(for operatorName: String) throws -> [PackageEntity] {
        return cachedPackagesToReturn.filter { $0.operatorName == operatorName }
    }

    func prefetchPackages() async {
        prefetchCallCount += 1
    }

    func saveTransaction(_ transaction: TransactionHistory) throws {
        savedTransactions.append(transaction)
    }

    func performRecharge(
        phone: String,
        operatorName: String,
        planTitle: String,
        amount: Double
    ) async throws -> TransactionHistory {
        if shouldFailRecharge {
            throw AppError.networkFailure
        }

        let txn = transactionToReturnOnRecharge ?? TransactionHistory.createTopUp(
            mobileNumber: phone,
            operatorName: operatorName,
            planDetails: planTitle,
            amount: amount,
            status: .success,
            fee: 0.0,
            referenceNumber: "TXN-TEST-12345"
        )
        savedTransactions.append(txn)
        return txn
    }
}
