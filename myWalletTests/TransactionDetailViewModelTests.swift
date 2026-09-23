//
//  TransactionDetailViewModelTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("TransactionDetailViewModel Tests")
@MainActor
struct TransactionDetailViewModelTests {

    private func makeSUT(
        referenceNumber: String = "20260923-00001",
        transactionToReturn: TransactionHistory? = nil,
        router: MockAppRouter? = nil
    ) -> (TransactionDetailViewModel, MockTransactionRepository, MockAppRouter) {
        let repo = MockTransactionRepository()
        if let transactionToReturn {
            repo.transactionsToReturn = [transactionToReturn]
        }
        let appRouter = router ?? MockAppRouter()
        let viewModel = TransactionDetailViewModel(
            referenceNumber: referenceNumber,
            transactionRepository: repo,
            router: appRouter
        )
        return (viewModel, repo, appRouter)
    }

    @Test("Loads existing transaction by reference number successfully")
    func loadsExistingTransaction() {
        let txn = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks Top-Up",
            amount: 1000,
            referenceNumber: "20260923-00001"
        )
        let (viewModel, repo, _) = makeSUT(
            referenceNumber: "20260923-00001",
            transactionToReturn: txn
        )

        #expect(repo.getTransactionByRefCallCount == 1)
        #expect(viewModel.transaction != nil)
        #expect(viewModel.transaction?.referenceNumber == "20260923-00001")
        #expect(viewModel.transaction?.mobileNumber == "09250000001")
        #expect(viewModel.transaction?.amount == 1000)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("Handles non-existent transaction gracefully with error message")
    func handlesNonExistentTransaction() {
        let (viewModel, repo, _) = makeSUT(
            referenceNumber: "NON-EXISTENT",
            transactionToReturn: nil
        )

        #expect(repo.getTransactionByRefCallCount == 1)
        #expect(viewModel.transaction == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("Copy reference number sets isCopied flag")
    func copyReferenceNumber() {
        let txn = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks",
            amount: 1000,
            referenceNumber: "20260923-COPY-ME"
        )
        let (viewModel, _, _) = makeSUT(
            referenceNumber: "20260923-COPY-ME",
            transactionToReturn: txn
        )

        #expect(viewModel.isCopied == false)
        viewModel.copyReferenceNumber()
        #expect(viewModel.isCopied == true)
    }

    @Test("canRecharge is true for Top-Up transactions")
    func canRechargeIsTrueForTopUp() {
        let txn = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks",
            amount: 1000,
            referenceNumber: "20260923-TOPUP"
        )
        let (viewModel, _, _) = makeSUT(
            referenceNumber: "20260923-TOPUP",
            transactionToReturn: txn
        )

        #expect(viewModel.canRecharge == true)
    }

    @Test("canRecharge is false for Transfer transactions")
    func canRechargeIsFalseForTransfer() {
        let txn = TransactionHistory.createTransfer(
            accountOrPhone: "09770000002",
            recipientName: "Daw Mya",
            amount: 5000,
            referenceNumber: "20260923-XFER"
        )
        let (viewModel, _, _) = makeSUT(
            referenceNumber: "20260923-XFER",
            transactionToReturn: txn
        )

        #expect(viewModel.canRecharge == false)
    }

    @Test("proceedToRecharge clears home stack and navigates directly to TopUpDetail confirmation")
    func proceedToRechargeNavigatesToTopUpDetail() {
        let txn = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks Top-Up",
            amount: 1000,
            fee: 0,
            referenceNumber: "20260923-00001"
        )
        let (viewModel, _, router) = makeSUT(
            referenceNumber: "20260923-00001",
            transactionToReturn: txn
        )

        viewModel.proceedToRecharge()

        #expect(router.popToRootCallCount == 1)
        #expect(router.navigatedRoutes.count == 1)

        guard case .topUpDetail(let params) = router.navigatedRoutes.first else {
            Issue.record("Expected .topUpDetail route")
            return
        }
        #expect(params.phone == "09250000001")
        #expect(params.operatorType == .mpt)
        #expect(params.amount == 1000)
        #expect(params.planTitle == "1,000 Ks Top-Up")
    }

    @Test("Generic view protocol decoupling allows mock view model")
    func genericViewModelDecoupling() {
        let txn = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks",
            amount: 1000,
            referenceNumber: "20260923-00001"
        )
        let mockVM = MockTransactionDetailViewModel(
            referenceNumber: "20260923-00001",
            transaction: txn
        )
        let view = TransactionDetailView(viewModel: mockVM)
        #expect(view.referenceNumber == "20260923-00001")
    }
}
