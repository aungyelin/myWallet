//
//  HomeViewModel.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation
import Observation

@Observable
@MainActor
public final class HomeViewModel: HomeViewModelProtocol {
    
    public private(set) var isBalanceHidden: Bool
    public private(set) var balance: Double
    private let router: any AppRouterProtocol
    
    public var formattedBalance: String {
        CurrencyFormatter.format(balance)
    }
    
    public var displayBalance: String {
        if isBalanceHidden {
            return AppLocalization.string("home_balance_hidden_mask")
        } else {
            return formattedBalance
        }
    }
    
    public init(
        router: any AppRouterProtocol,
        initialBalance: Double = 1_250_000,
        isBalanceHidden: Bool = false
    ) {
        self.router = router
        self.balance = initialBalance
        self.isBalanceHidden = isBalanceHidden
    }
    
    public func toggleBalanceVisibility() {
        isBalanceHidden.toggle()
    }
    
    public func navigateToTopUp() {
        router.navigate(to: .topUp)
    }

    public func navigateToHistory() {
        router.navigate(to: .transactionHistory)
    }
    
}
