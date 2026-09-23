//
//  AppContainerProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData

@MainActor
public protocol AppContainerProtocol: AnyObject {
    
    var modelContainer: ModelContainer { get }
    var networkService: MockNetworkServiceProtocol { get }
    var telecomRepository: TelecomRepositoryProtocol { get }
    var topUpRepository: TopUpRepositoryProtocol { get }
    var transactionRepository: TransactionRepositoryProtocol { get }
    var themeManager: ThemeManagerProtocol { get }
    var languageManager: LanguageManagerProtocol { get }
    var appRouter: any AppRouterProtocol { get }

    func makeTopUpViewModel() -> TopUpViewModel
    func makeHomeViewModel() -> HomeViewModel
    func makeTopUpDetailViewModel(params: TopUpCheckoutParams) -> TopUpDetailViewModel
    func makeTransactionHistoryViewModel() -> TransactionHistoryViewModel
    func makeTransactionDetailViewModel(referenceNumber: String) -> TransactionDetailViewModel
    
}

extension AppContainerProtocol {
    public func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(router: appRouter)
    }

    public func makeTopUpViewModel() -> TopUpViewModel {
        TopUpViewModel(
            telecomRepository: telecomRepository,
            topUpRepository: topUpRepository,
            router: appRouter
        )
    }

    public func makeTopUpDetailViewModel(params: TopUpCheckoutParams) -> TopUpDetailViewModel {
        TopUpDetailViewModel(
            params: params,
            topUpRepository: topUpRepository,
            transactionRepository: transactionRepository,
            router: appRouter
        )
    }

    public func makeTransactionHistoryViewModel() -> TransactionHistoryViewModel {
        TransactionHistoryViewModel(
            transactionRepository: transactionRepository,
            router: appRouter
        )
    }

    public func makeTransactionDetailViewModel(referenceNumber: String) -> TransactionDetailViewModel {
        TransactionDetailViewModel(
            referenceNumber: referenceNumber,
            transactionRepository: transactionRepository,
            router: appRouter
        )
    }
}
