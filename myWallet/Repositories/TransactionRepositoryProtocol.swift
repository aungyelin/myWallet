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
    ///   - operatorFilter: Optional telecom operator code (e.g. "MPT", "ATOM") or `nil` for all operators.
    ///   - typeFilter: Optional transaction type (top-up, transfer, payment) or `nil` for all types.
    ///   - statusFilter: Optional status (success, pending, failed) or `nil` for all statuses.
    /// - Returns: Filtered list of `TransactionHistory` records.
    func getTransactions(
        query: String?,
        operatorFilter: String?,
        typeFilter: TransactionType?,
        statusFilter: TransactionStatus?
    ) throws -> [TransactionHistory]

    /// Fetches all transactions sorted by date descending without filters.
    func getAllTransactions() throws -> [TransactionHistory]

    func saveTransaction(_ transaction: TransactionHistory) throws
    
}

public extension TransactionRepositoryProtocol {
    func getTransactions(
        query: String? = nil,
        operatorFilter: String? = nil,
        typeFilter: TransactionType? = nil,
        statusFilter: TransactionStatus? = nil
    ) throws -> [TransactionHistory] {
        try getTransactions(
            query: query,
            operatorFilter: operatorFilter,
            typeFilter: typeFilter,
            statusFilter: statusFilter
        )
    }
}
