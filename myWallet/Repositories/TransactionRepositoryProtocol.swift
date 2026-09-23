//
//  TransactionRepositoryProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation
import SwiftData

@MainActor
public protocol TransactionRepositoryProtocol: AnyObject {
    
    /// Retrieves stored transactions with optional filtering and query search, sorted by date descending.
    /// - Parameters:
    ///   - query: Optional search string matching phone number, operator name, reference number, or counterparty.
    ///   - operatorFilter: Optional telecom operator (e.g. .mpt, .atom) or `nil` for all operators.
    ///   - typeFilter: Optional transaction type (top-up, transfer, payment) or `nil` for all types.
    ///   - statusFilter: Optional status (success, pending, failed) or `nil` for all statuses.
    ///   - startDate: Optional lower date boundary (inclusive).
    ///   - endDate: Optional upper date boundary (inclusive).
    /// - Returns: Filtered list of `TransactionHistory` records.
    func getTransactions(
        query: String?,
        operatorFilter: TelecomOperator?,
        typeFilter: TransactionType?,
        statusFilter: TransactionStatus?,
        startDate: Date?,
        endDate: Date?
    ) throws -> [TransactionHistory]

    /// Fetches a specific transaction by its unique reference number.
    func getTransaction(by referenceNumber: String) throws -> TransactionHistory?

    func saveTransaction(_ transaction: TransactionHistory) throws
    
}

public extension TransactionRepositoryProtocol {
    func getTransactions(
        query: String? = nil,
        operatorFilter: TelecomOperator? = nil,
        typeFilter: TransactionType? = nil,
        statusFilter: TransactionStatus? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) throws -> [TransactionHistory] {
        try getTransactions(
            query: query,
            operatorFilter: operatorFilter,
            typeFilter: typeFilter,
            statusFilter: statusFilter,
            startDate: startDate,
            endDate: endDate
        )
    }
}
