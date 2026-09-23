//
//  MockTransactionDetailViewModel.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation
@testable import myWallet

@Observable
@MainActor
final class MockTransactionDetailViewModel: TransactionDetailViewModelProtocol {
    var referenceNumber: String
    var transaction: TransactionHistory?
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isCopied: Bool = false
    var loadTransactionCallCount = 0
    var copyReferenceNumberCallCount = 0
    var proceedToRechargeCallCount = 0

    var canRecharge: Bool {
        transaction?.parsedType == .topUp
    }

    init(referenceNumber: String, transaction: TransactionHistory? = nil) {
        self.referenceNumber = referenceNumber
        self.transaction = transaction
    }

    func loadTransaction() {
        loadTransactionCallCount += 1
    }

    func copyReferenceNumber() {
        copyReferenceNumberCallCount += 1
        isCopied = true
    }

    func proceedToRecharge() {
        proceedToRechargeCallCount += 1
    }
}
