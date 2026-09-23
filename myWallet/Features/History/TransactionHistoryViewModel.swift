//
//  TransactionHistoryViewModel.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
public final class TransactionHistoryViewModel: TransactionHistoryViewModelProtocol {
    
    public private(set) var transactions: [TransactionHistory] = []
    public var availableOperators: [TelecomOperator] {
        TelecomOperator.allCases.filter { $0 != .unknown }
    }
    public var searchQuery: String = ""
    public var selectedOperator: TelecomOperator? = nil
    public var selectedStatus: TransactionStatus? = nil
    public var selectedDateFilter: TransactionDateFilter = .all
    public var customStartDate: Date = Date()
    public var customEndDate: Date = Date()
    public var isFilterSheetPresented: Bool = false
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String? = nil

    public var hasActiveFilters: Bool {
        selectedOperator != nil || selectedStatus != nil || selectedDateFilter != .all
    }

    private let transactionRepository: TransactionRepositoryProtocol
    public let debounceNanoseconds: UInt64
    private var debounceTask: Task<Void, Never>?
    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: Constants.Logging.repositoryCategory
    )

    public init(
        transactionRepository: TransactionRepositoryProtocol,
        debounceNanoseconds: UInt64 = 150_000_000
    ) {
        self.transactionRepository = transactionRepository
        self.debounceNanoseconds = debounceNanoseconds
        loadTransactions()
    }

    public func loadTransactions() {
        isLoading = true
        errorMessage = nil

        let boundaries = selectedDateFilter.dateBoundaries()

        do {
            self.transactions = try transactionRepository.getTransactions(
                query: searchQuery.isEmpty ? nil : searchQuery,
                operatorFilter: selectedOperator,
                typeFilter: nil,
                statusFilter: selectedStatus,
                startDate: boundaries.start,
                endDate: boundaries.end
            )
            isLoading = false
        } catch {
            logger.error("Failed to load transactions: \(error.localizedDescription, privacy: .public)")
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    public func onSearchQueryChanged(_ query: String) async {
        debounceTask?.cancel()
        self.searchQuery = query

        let task = Task { [weak self] in
            if let debounce = self?.debounceNanoseconds, debounce > 0 {
                try? await Task.sleep(nanoseconds: debounce)
            }
            guard !Task.isCancelled, let self else { return }
            self.loadTransactions()
        }
        self.debounceTask = task
        await task.value
    }

    public func selectOperator(_ op: TelecomOperator?) {
        self.selectedOperator = op
        loadTransactions()
    }

    public func selectStatus(_ status: TransactionStatus?) {
        self.selectedStatus = status
        loadTransactions()
    }

    public func selectDateFilter(_ filter: TransactionDateFilter) {
        self.selectedDateFilter = filter
        loadTransactions()
    }

    public func applyCustomDateRange(start: Date, end: Date) {
        self.customStartDate = start
        self.customEndDate = end
        self.selectedDateFilter = .custom(start: start, end: end)
        loadTransactions()
    }

    public func resetFilters() {
        self.selectedOperator = nil
        self.selectedStatus = nil
        self.selectedDateFilter = .all
        self.searchQuery = ""
        loadTransactions()
    }

    public func selectTransaction(_ transaction: TransactionHistory, router: (any AppRouterProtocol)?) {
        router?.navigate(to: .transactionDetail(referenceNumber: transaction.referenceNumber))
    }
    
}
