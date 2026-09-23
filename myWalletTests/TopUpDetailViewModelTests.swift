//
//  TopUpDetailViewModelTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("TopUpDetailViewModel Tests")
@MainActor
struct TopUpDetailViewModelTests {

    private func makeParams() -> TopUpCheckoutParams {
        TopUpCheckoutParams(
            phone: "09253366392",
            operatorType: .mpt,
            planTitle: "Combo 1000MB (YouTube; TikTok; Telegram) (7 Days)",
            amount: 998
        )
    }

    @Test("Successful payment calls repository performRecharge and navigates to TopUpSuccess")
    func successfulPayment() async {
        let params = makeParams()
        let topUpRepo = MockTopUpRepository()
        let transactionRepo = MockTransactionRepository()
        let router = MockAppRouter()

        let viewModel = TopUpDetailViewModel(
            params: params,
            topUpRepository: topUpRepo,
            transactionRepository: transactionRepo,
            router: router
        )

        #expect(viewModel.isProcessing == false)
        #expect(viewModel.errorMessage == nil)

        await viewModel.confirmPayment()

        #expect(viewModel.isProcessing == false)
        #expect(viewModel.errorMessage == nil)
        #expect(transactionRepo.savedTransactions.count == 1)

        let saved = transactionRepo.savedTransactions.first
        #expect(saved?.mobileNumber == "09253366392")
        #expect(saved?.operatorName == "MPT")
        #expect(saved?.amount == 998)
        #expect(saved?.referenceNumber == "20260923-123456")

        #expect(router.navigatedRoutes.count == 1)
        guard case .topUpSuccess(let receiptParams) = router.navigatedRoutes.first else {
            Issue.record("Expected .topUpSuccess route")
            return
        }

        #expect(receiptParams.phone == "09253366392")
        #expect(receiptParams.referenceNumber == "20260923-123456")
        #expect(receiptParams.operatorType == .mpt)
        #expect(receiptParams.amount == 998)
    }

    @Test("Payment failure sets errorMessage and does not navigate")
    func paymentFailure() async {
        let params = makeParams()
        let topUpRepo = MockTopUpRepository()
        let transactionRepo = MockTransactionRepository()
        topUpRepo.shouldFailRecharge = true
        let router = MockAppRouter()

        let viewModel = TopUpDetailViewModel(
            params: params,
            topUpRepository: topUpRepo,
            transactionRepository: transactionRepo,
            router: router
        )

        await viewModel.confirmPayment()

        #expect(viewModel.isProcessing == false)
        #expect(viewModel.errorMessage != nil)
        #expect(router.navigatedRoutes.isEmpty)
        #expect(transactionRepo.savedTransactions.isEmpty)
    }
    
}
