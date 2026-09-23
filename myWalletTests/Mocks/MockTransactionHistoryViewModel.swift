//
//  MockTransactionHistoryViewModel.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation
@testable import myWallet

@Observable
@MainActor
final class MockTransactionHistoryViewModel: TransactionHistoryViewModelProtocol {
    var transactions: [TransactionHistory] = []
    var availableOperators: [TelecomOperator] = TelecomOperator.allCases.filter { $0 != .unknown }
    var searchQuery: String = ""
    var selectedOperator: TelecomOperator? = nil
    var selectedStatus: TransactionStatus? = nil
    var selectedDateFilter: TransactionDateFilter = .all
    var customStartDate: Date = Date()
    var customEndDate: Date = Date()
    var isFilterSheetPresented: Bool = false
    var hasActiveFilters: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var loadTransactionsCallCount = 0
    var onSearchQueryChangedCallCount = 0
    var selectOperatorCallCount = 0
    var selectStatusCallCount = 0
    var selectDateFilterCallCount = 0
    var resetFiltersCallCount = 0
    var selectedTransaction: TransactionHistory?

    func loadTransactions() {
        loadTransactionsCallCount += 1
    }

    func onSearchQueryChanged(_ query: String) async {
        onSearchQueryChangedCallCount += 1
        searchQuery = query
    }

    func selectOperator(_ op: TelecomOperator?) {
        selectOperatorCallCount += 1
        selectedOperator = op
    }

    func selectStatus(_ status: TransactionStatus?) {
        selectStatusCallCount += 1
        selectedStatus = status
    }

    func selectDateFilter(_ filter: TransactionDateFilter) {
        selectDateFilterCallCount += 1
        selectedDateFilter = filter
    }

    func applyCustomDateRange(start: Date, end: Date) {
        customStartDate = start
        customEndDate = end
        selectedDateFilter = .custom(start: start, end: end)
    }

    func resetFilters() {
        resetFiltersCallCount += 1
        selectedOperator = nil
        selectedStatus = nil
        selectedDateFilter = .all
        searchQuery = ""
    }

    func selectTransaction(_ transaction: TransactionHistory, router: (any AppRouterProtocol)?) {
        selectedTransaction = transaction
        router?.navigate(to: .transactionDetail(referenceNumber: transaction.referenceNumber))
    }
}
