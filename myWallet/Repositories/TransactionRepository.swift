//
//  TransactionRepository.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation
import SwiftData
import OSLog

/// Concrete repository coordinating querying, searching, filtering, and persistence for banking transactions.
@MainActor
public final class TransactionRepository: TransactionRepositoryProtocol {
    
    private let modelContext: ModelContext
    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: Constants.Logging.repositoryCategory
    )

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func getAllTransactions() throws -> [TransactionHistory] {
        try getTransactions(
            query: nil,
            operatorFilter: nil,
            typeFilter: nil,
            statusFilter: nil,
            startDate: nil,
            endDate: nil
        )
    }

    public func getTransactions(
        query: String?,
        operatorFilter: TelecomOperator?,
        typeFilter: TransactionType?,
        statusFilter: TransactionStatus?,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) throws -> [TransactionHistory] {
        let descriptor = FetchDescriptor<TransactionHistory>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let allTransactions = try modelContext.fetch(descriptor)
        
        return allTransactions.filter { item in
            // 1. Date Range Boundaries
            if let startDate, item.date < startDate {
                return false
            }
            if let endDate, item.date > endDate {
                return false
            }

            // 2. Operator Filter
            if let op = operatorFilter {
                guard item.operatorType == op else {
                    return false
                }
            }

            // 3. Transaction Type Filter
            if let type = typeFilter {
                guard item.parsedType == type else {
                    return false
                }
            }

            // 4. Transaction Status Filter
            if let status = statusFilter {
                guard item.parsedStatus == status else {
                    return false
                }
            }

            // 5. Text Search Query
            if let rawQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines), !rawQuery.isEmpty {
                let lowerQuery = rawQuery.lowercased()
                let matchesReference = item.referenceNumber.lowercased().contains(lowerQuery)
                let matchesCounterparty = item.counterparty.lowercased().contains(lowerQuery)
                let matchesRecipient = item.recipientName?.lowercased().contains(lowerQuery) ?? false
                let matchesMobile = item.mobileNumber?.lowercased().contains(lowerQuery) ?? false
                let matchesOperator = item.operatorName?.lowercased().contains(lowerQuery) ?? false
                let matchesPlan = item.planDetails?.lowercased().contains(lowerQuery) ?? false
                let matchesRemark = item.remark?.lowercased().contains(lowerQuery) ?? false

                guard matchesReference || matchesCounterparty || matchesRecipient ||
                      matchesMobile || matchesOperator || matchesPlan || matchesRemark else {
                    return false
                }
            }

            return true
        }
    }

    public func getTransaction(by referenceNumber: String) throws -> TransactionHistory? {
        let cleanRef = referenceNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanRef.isEmpty else { return nil }
        
        let descriptor = FetchDescriptor<TransactionHistory>(
            predicate: #Predicate { $0.referenceNumber == cleanRef }
        )
        let results = try modelContext.fetch(descriptor)
        return results.first
    }

    public func saveTransaction(_ transaction: TransactionHistory) throws {
        modelContext.insert(transaction)
        do {
            try modelContext.save()
            logger.info("Transaction \(transaction.referenceNumber, privacy: .public) persisted successfully.")
        } catch {
            logger.error("Failed to persist transaction to SwiftData: \(error.localizedDescription, privacy: .public)")
            throw AppError.persistenceFailure(error.localizedDescription)
        }
    }
    
}
