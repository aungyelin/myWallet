//
//  TransactionHistoryViewModelTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("TransactionHistoryViewModel Tests")
@MainActor
struct TransactionHistoryViewModelTests {

    private func makeSampleTransactions() -> [TransactionHistory] {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        let eightDaysAgo = calendar.date(byAdding: .day, value: -8, to: now)!

        let t1 = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks Top-Up",
            amount: 1000,
            status: .success,
            date: now,
            referenceNumber: "20260923-00001"
        )
        let t2 = TransactionHistory.createTopUp(
            mobileNumber: "09770000002",
            operatorName: "ATOM",
            planDetails: "2,000 Ks Top-Up",
            amount: 2000,
            status: .pending,
            date: twoDaysAgo,
            referenceNumber: "20260921-00002"
        )
        let t3 = TransactionHistory.createTransfer(
            accountOrPhone: "09990000003",
            recipientName: "Daw Mya",
            amount: 15000,
            status: .failed,
            date: eightDaysAgo,
            referenceNumber: "20260915-00003"
        )
        return [t1, t2, t3]
    }

    private func makeSUT(
        transactions: [TransactionHistory] = [],
        debounceNanoseconds: UInt64 = 0
    ) -> (TransactionHistoryViewModel, MockTransactionRepository) {
        let repo = MockTransactionRepository()
        repo.transactionsToReturn = transactions
        let viewModel = TransactionHistoryViewModel(
            transactionRepository: repo,
            debounceNanoseconds: debounceNanoseconds
        )
        return (viewModel, repo)
    }

    @Test("Initial load fetches transactions from repository")
    func initialLoad() {
        let sample = makeSampleTransactions()
        let (viewModel, repo) = makeSUT(transactions: sample)

        #expect(repo.getTransactionsCallCount == 1)
        #expect(viewModel.transactions.count == 3)
        #expect(viewModel.searchQuery.isEmpty)
        #expect(viewModel.selectedOperator == nil)
        #expect(viewModel.selectedStatus == nil)
        #expect(viewModel.selectedDateFilter == .all)
        #expect(viewModel.hasActiveFilters == false)
    }

    @Test("Search query debouncing and structured task cancellation")
    func searchQueryDebouncing() async {
        let sample = makeSampleTransactions()
        let (viewModel, _) = makeSUT(transactions: sample, debounceNanoseconds: 50_000_000)

        // Rapid keystroke 1
        let task1 = Task {
            await viewModel.onSearchQueryChanged("092")
        }

        // Allow task1 to start on MainActor before sending keystroke 2
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Rapid keystroke 2 cancels earlier task
        let task2 = Task {
            await viewModel.onSearchQueryChanged("ATOM")
        }

        _ = await task1.result
        _ = await task2.result

        #expect(viewModel.searchQuery == "ATOM")
        #expect(viewModel.transactions.count == 1)
        #expect(viewModel.transactions.first?.operatorName == "ATOM")
    }

    @Test("Exposes non-unknown available operators")
    func availableOperators() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.availableOperators == [.mpt, .atom, .u9, .mytel])
    }

    @Test("Filter by operator switches active filter and queries repository")
    func filterByOperator() {
        let sample = makeSampleTransactions()
        let (viewModel, repo) = makeSUT(transactions: sample)

        viewModel.selectOperator(.mpt)
        #expect(viewModel.selectedOperator == .mpt)
        #expect(viewModel.hasActiveFilters == true)
        #expect(repo.lastOperatorFilter == .mpt)
        #expect(viewModel.transactions.count == 1)
        #expect(viewModel.transactions.first?.operatorName == "MPT")

        // Switch to nil resets operator filter
        viewModel.selectOperator(nil)
        #expect(viewModel.selectedOperator == nil)
        #expect(repo.lastOperatorFilter == nil)
        #expect(viewModel.transactions.count == 3)
    }

    @Test("Filter by status updates results")
    func filterByStatus() {
        let sample = makeSampleTransactions()
        let (viewModel, repo) = makeSUT(transactions: sample)

        viewModel.selectStatus(.pending)
        #expect(viewModel.selectedStatus == .pending)
        #expect(viewModel.hasActiveFilters == true)
        #expect(repo.lastStatusFilter == .pending)
        #expect(viewModel.transactions.count == 1)
        #expect(viewModel.transactions.first?.parsedStatus == .pending)

        // Reset status filter
        viewModel.selectStatus(nil)
        #expect(viewModel.selectedStatus == nil)
        #expect(viewModel.transactions.count == 3)
    }

    @Test("Filter by date range presets restricts returned records")
    func filterByDateRange() {
        let sample = makeSampleTransactions()
        let (viewModel, _) = makeSUT(transactions: sample)

        // Last 7 days: should include t1 (now) and t2 (2 days ago), but not t3 (8 days ago)
        viewModel.selectDateFilter(.last7Days)
        #expect(viewModel.selectedDateFilter == .last7Days)
        #expect(viewModel.hasActiveFilters == true)
        #expect(viewModel.transactions.count == 2)

        // Today: should only include t1
        viewModel.selectDateFilter(.today)
        #expect(viewModel.transactions.count == 1)

        // All Time
        viewModel.selectDateFilter(.all)
        #expect(viewModel.transactions.count == 3)
    }

    @Test("Reset filters clears all search and filter properties")
    func resetFilters() {
        let sample = makeSampleTransactions()
        let (viewModel, _) = makeSUT(transactions: sample)

        viewModel.selectOperator(.mpt)
        viewModel.selectStatus(.success)
        viewModel.selectDateFilter(.last7Days)
        #expect(viewModel.hasActiveFilters == true)

        viewModel.resetFilters()
        #expect(viewModel.selectedOperator == nil)
        #expect(viewModel.selectedStatus == nil)
        #expect(viewModel.selectedDateFilter == .all)
        #expect(viewModel.searchQuery.isEmpty)
        #expect(viewModel.hasActiveFilters == false)
        #expect(viewModel.transactions.count == 3)
    }

    @Test("Selecting transaction navigates to transaction detail")
    func selectTransactionNavigates() {
        let sample = makeSampleTransactions()
        let (viewModel, _) = makeSUT(transactions: sample)
        let router = MockAppRouter()

        viewModel.selectTransaction(sample[0], router: router)
        #expect(router.navigatedRoutes.count == 1)
        #expect(router.navigatedRoutes.first == .transactionDetail(referenceNumber: sample[0].referenceNumber))
    }

    @Test("Generic view protocol decoupling supports mock view model without runtime cast")
    func genericViewModelDecoupling() {
        let mockVM = MockTransactionHistoryViewModel()
        mockVM.transactions = makeSampleTransactions()
        let view = TransactionHistoryView(viewModel: mockVM)
        #expect(view != nil)
    }
}
