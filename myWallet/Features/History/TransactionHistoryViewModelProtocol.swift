//
//  TransactionHistoryViewModelProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation

@MainActor
public protocol TransactionHistoryViewModelProtocol: AnyObject, Observable {
    
    var transactions: [TransactionHistory] { get }
    var availableOperators: [TelecomOperator] { get }
    var searchQuery: String { get set }
    var selectedOperator: TelecomOperator? { get set }
    var selectedStatus: TransactionStatus? { get set }
    var selectedDateFilter: TransactionDateFilter { get set }
    var customStartDate: Date { get set }
    var customEndDate: Date { get set }
    var isFilterSheetPresented: Bool { get set }
    var hasActiveFilters: Bool { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    func loadTransactions()
    func onSearchQueryChanged(_ query: String) async
    func selectOperator(_ op: TelecomOperator?)
    func selectStatus(_ status: TransactionStatus?)
    func selectDateFilter(_ filter: TransactionDateFilter)
    func applyCustomDateRange(start: Date, end: Date)
    func resetFilters()
    func selectTransaction(_ transaction: TransactionHistory, router: (any AppRouterProtocol)?)
    
}
