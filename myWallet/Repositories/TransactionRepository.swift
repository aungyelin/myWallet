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
        try getTransactions(query: nil, operatorFilter: nil, typeFilter: nil, statusFilter: nil)
    }

    public func getTransactions(
        query: String?,
        operatorFilter: String?,
        typeFilter: TransactionType?,
        statusFilter: TransactionStatus?
    ) throws -> [TransactionHistory] {
        let descriptor = FetchDescriptor<TransactionHistory>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let allTransactions = try modelContext.fetch(descriptor)
        
        return allTransactions.filter { item in
            // 1. Operator Filter
            if let op = operatorFilter?.trimmingCharacters(in: .whitespacesAndNewlines),
               !op.isEmpty, op.lowercased() != "all" {
                guard let itemOp = item.operatorName, itemOp.caseInsensitiveCompare(op) == .orderedSame else {
                    return false
                }
            }

            // 2. Transaction Type Filter
            if let type = typeFilter {
                guard item.parsedType == type else {
                    return false
                }
            }

            // 3. Transaction Status Filter
            if let status = statusFilter {
                guard item.parsedStatus == status else {
                    return false
                }
            }

            // 4. Text Search Query
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
