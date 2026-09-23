//
//  TopUpDetailViewModel.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
public final class TopUpDetailViewModel: TopUpDetailViewModelProtocol {

    public let params: TopUpCheckoutParams
    public private(set) var isProcessing: Bool = false
    public private(set) var errorMessage: String? = nil

    private let topUpRepository: TopUpRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let router: any AppRouterProtocol
    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: "TopUpDetailViewModel"
    )

    public init(
        params: TopUpCheckoutParams,
        topUpRepository: TopUpRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol,
        router: any AppRouterProtocol
    ) {
        self.params = params
        self.topUpRepository = topUpRepository
        self.transactionRepository = transactionRepository
        self.router = router
    }

    public func confirmPayment() async {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            let response = try await topUpRepository.performRecharge(
                phone: params.phone,
                operatorName: params.operatorType.rawValue,
                planTitle: params.planTitle,
                amount: params.amount
            )

            let transaction = TransactionHistory.createTopUp(
                mobileNumber: response.mobileNumber,
                operatorName: response.operatorName,
                planDetails: response.planDetails,
                amount: response.amount,
                status: .success,
                fee: response.fee,
                date: response.timestamp,
                referenceNumber: response.referenceNumber
            )
            try transactionRepository.saveTransaction(transaction)

            let receiptParams = TopUpReceiptParams(
                referenceNumber: transaction.referenceNumber,
                phone: transaction.mobileNumber ?? params.phone,
                operatorType: params.operatorType,
                planTitle: transaction.planDetails ?? params.planTitle,
                amount: transaction.amount,
                fee: transaction.fee,
                timestamp: transaction.date
            )

            logger.info("Recharge succeeded and transaction was persisted.")
            router.navigate(to: .topUpSuccess(receiptParams))
        } catch {
            logger.error("Recharge payment failed: \(error.localizedDescription, privacy: .public)")
            self.errorMessage = error.localizedDescription
        }
    }
    
}
