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
        let router = MockAppRouter()

        let viewModel = TopUpDetailViewModel(
            params: params,
            topUpRepository: topUpRepo
        )

        #expect(viewModel.isProcessing == false)
        #expect(viewModel.errorMessage == nil)

        await viewModel.confirmPayment(router: router)

        #expect(viewModel.isProcessing == false)
        #expect(viewModel.errorMessage == nil)
        #expect(topUpRepo.savedTransactions.count == 1)

        let saved = topUpRepo.savedTransactions.first
        #expect(saved?.mobileNumber == "09253366392")
        #expect(saved?.operatorName == "MPT")
        #expect(saved?.amount == 998)
        #expect(saved?.referenceNumber == "TXN-TEST-12345")

        #expect(router.navigatedRoutes.count == 1)
        guard case .topUpSuccess(let receiptParams) = router.navigatedRoutes.first else {
            Issue.record("Expected .topUpSuccess route")
            return
        }

        #expect(receiptParams.phone == "09253366392")
        #expect(receiptParams.referenceNumber == "TXN-TEST-12345")
        #expect(receiptParams.operatorType == .mpt)
        #expect(receiptParams.amount == 998)
    }

    @Test("Payment failure sets errorMessage and does not navigate")
    func paymentFailure() async {
        let params = makeParams()
        let topUpRepo = MockTopUpRepository()
        topUpRepo.shouldFailRecharge = true
        let router = MockAppRouter()

        let viewModel = TopUpDetailViewModel(
            params: params,
            topUpRepository: topUpRepo
        )

        await viewModel.confirmPayment(router: router)

        #expect(viewModel.isProcessing == false)
        #expect(viewModel.errorMessage != nil)
        #expect(router.navigatedRoutes.isEmpty)
        #expect(topUpRepo.savedTransactions.isEmpty)
    }
}
