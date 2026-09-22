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
    
    public var formattedBalance: String {
        CurrencyFormatter.format(balance)
    }
    
    public var displayBalance: String {
        if isBalanceHidden {
            return String(localized: "home_balance_hidden_mask")
        } else {
            return formattedBalance
        }
    }
    
    public init(
        initialBalance: Double = 1_250_000,
        isBalanceHidden: Bool = false
    ) {
        self.balance = initialBalance
        self.isBalanceHidden = isBalanceHidden
    }
    
    public func toggleBalanceVisibility() {
        isBalanceHidden.toggle()
    }
    
    public func navigateToTopUp(router: (any AppRouterProtocol)?) {
        router?.navigate(to: .topUp)
    }
    
    public func navigateToHistory(router: (any AppRouterProtocol)?) {
        router?.navigate(to: .transactionHistory)
    }
    
}
