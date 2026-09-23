//
//  TransactionDetailViewModel.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation
import OSLog
#if canImport(UIKit)
import UIKit
#endif

@Observable
@MainActor
public final class TransactionDetailViewModel: TransactionDetailViewModelProtocol {
    
    public let referenceNumber: String
    public private(set) var transaction: TransactionHistory?
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String? = nil
    public private(set) var isCopied: Bool = false

    private let transactionRepository: TransactionRepositoryProtocol
    private let router: (any AppRouterProtocol)?
    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: Constants.Logging.repositoryCategory
    )

    public var canRecharge: Bool {
        transaction?.parsedType == .topUp
    }

    public init(
        referenceNumber: String,
        transactionRepository: TransactionRepositoryProtocol,
        router: (any AppRouterProtocol)? = nil
    ) {
        self.referenceNumber = referenceNumber
        self.transactionRepository = transactionRepository
        self.router = router
        loadTransaction()
    }

    public func loadTransaction() {
        isLoading = true
        errorMessage = nil

        do {
            self.transaction = try transactionRepository.getTransaction(by: referenceNumber)
            isLoading = false
            if transaction == nil {
                errorMessage = String(localized: "transaction_not_found")
            }
        } catch {
            logger.error("Failed to load transaction \(self.referenceNumber, privacy: .public): \(error.localizedDescription, privacy: .public)")
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    public func copyReferenceNumber() {
        #if canImport(UIKit)
        UIPasteboard.general.string = referenceNumber
        #endif
        isCopied = true
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled, let self else { return }
            self.isCopied = false
        }
    }

    public func proceedToRecharge() {
        guard let transaction, transaction.parsedType == .topUp else { return }
        guard let router else { return }

        let phone = transaction.mobileNumber ?? transaction.counterparty
        let checkoutParams = TopUpCheckoutParams(
            phone: phone,
            operatorType: transaction.operatorType,
            planTitle: transaction.planDetails ?? "\(CurrencyFormatter.format(transaction.amount)) \(String(localized: "top_up_title"))",
            amount: transaction.amount,
            fee: transaction.fee
        )

        // Clear history stack to root of Home tab
        router.popToRoot(in: .home)
        // Navigate directly to the confirmation/checkout page
        router.navigate(to: .topUpDetail(checkoutParams))
    }
    
}
