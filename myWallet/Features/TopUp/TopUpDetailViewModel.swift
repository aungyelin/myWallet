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
    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: "TopUpDetailViewModel"
    )

    public init(
        params: TopUpCheckoutParams,
        topUpRepository: TopUpRepositoryProtocol
    ) {
        self.params = params
        self.topUpRepository = topUpRepository
    }

    public func confirmPayment(router: (any AppRouterProtocol)?) async {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            let transaction = try await topUpRepository.performRecharge(
                phone: params.phone,
                operatorName: params.operatorType.rawValue,
                planTitle: params.planTitle,
                amount: params.amount
            )

            let receiptParams = TopUpReceiptParams(
                referenceNumber: transaction.referenceNumber,
                phone: transaction.mobileNumber ?? params.phone,
                operatorType: params.operatorType,
                planTitle: transaction.planDetails ?? params.planTitle,
                amount: transaction.amount,
                fee: transaction.fee,
                timestamp: transaction.date
            )

            logger.info("Recharge succeeded with reference: \(transaction.referenceNumber, privacy: .public)")
            router?.navigate(to: .topUpSuccess(receiptParams))
        } catch {
            logger.error("Recharge payment failed: \(error.localizedDescription, privacy: .public)")
            self.errorMessage = error.localizedDescription
        }
    }
    
}
