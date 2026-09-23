//
//  MockTransactionRepository.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
@testable import myWallet

@MainActor
final class MockTransactionRepository: TransactionRepositoryProtocol {
    var transactionsToReturn: [TransactionHistory] = []
    var transactionByRefToReturn: TransactionHistory?
    var savedTransactions: [TransactionHistory] = []
    var shouldFail = false

    // Spies
    var lastQuery: String?
    var lastOperatorFilter: TelecomOperator?
    var lastTypeFilter: TransactionType?
    var lastStatusFilter: TransactionStatus?
    var lastStartDate: Date?
    var lastEndDate: Date?
    var getTransactionsCallCount = 0
    var getTransactionByRefCallCount = 0

    func getTransactions(
        query: String?,
        operatorFilter: TelecomOperator?,
        typeFilter: TransactionType?,
        statusFilter: TransactionStatus?,
        startDate: Date?,
        endDate: Date?
    ) throws -> [TransactionHistory] {
        getTransactionsCallCount += 1
        lastQuery = query
        lastOperatorFilter = operatorFilter
        lastTypeFilter = typeFilter
        lastStatusFilter = statusFilter
        lastStartDate = startDate
        lastEndDate = endDate

        if shouldFail {
            throw AppError.persistenceFailure("Mock persistence error")
        }

        var results = transactionsToReturn

        if let startDate {
            results = results.filter { $0.date >= startDate }
        }
        if let endDate {
            results = results.filter { $0.date <= endDate }
        }

        if let operatorFilter {
            results = results.filter { $0.operatorType == operatorFilter }
        }

        if let typeFilter {
            results = results.filter { $0.parsedType == typeFilter }
        }

        if let statusFilter {
            results = results.filter { $0.parsedStatus == statusFilter }
        }

        if let query = query?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty {
            let lower = query.lowercased()
            results = results.filter {
                $0.referenceNumber.lowercased().contains(lower) ||
                $0.counterparty.lowercased().contains(lower) ||
                ($0.mobileNumber?.lowercased().contains(lower) ?? false) ||
                ($0.operatorName?.lowercased().contains(lower) ?? false) ||
                ($0.planDetails?.lowercased().contains(lower) ?? false)
            }
        }

        return results
    }

    func getTransaction(by referenceNumber: String) throws -> TransactionHistory? {
        getTransactionByRefCallCount += 1
        if shouldFail {
            throw AppError.persistenceFailure("Mock persistence error")
        }
        if let transactionByRefToReturn {
            return transactionByRefToReturn
        }
        return transactionsToReturn.first { $0.referenceNumber == referenceNumber }
    }

    func saveTransaction(_ transaction: TransactionHistory) throws {
        if shouldFail {
            throw AppError.persistenceFailure("Mock persistence error")
        }
        savedTransactions.append(transaction)
        transactionsToReturn.insert(transaction, at: 0)
    }
}
