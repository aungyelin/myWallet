//
//  HomeViewModelTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("HomeViewModel Tests")
@MainActor
struct HomeViewModelTests {
    
    @Test("HomeViewModel initializes with default balance and visible state")
    func initialViewModelState() {
        let viewModel = HomeViewModel()
        
        #expect(viewModel.balance == 1_250_000)
        #expect(viewModel.isBalanceHidden == false)
        #expect(viewModel.formattedBalance.contains("1,250,000"))
        #expect(viewModel.displayBalance == viewModel.formattedBalance)
    }
    
    @Test("toggleBalanceVisibility alternates between formatted balance and hidden mask")
    func toggleBalanceVisibility() {
        let viewModel = HomeViewModel()
        
        #expect(viewModel.isBalanceHidden == false)
        #expect(viewModel.displayBalance == viewModel.formattedBalance)
        
        // Hide balance
        viewModel.toggleBalanceVisibility()
        #expect(viewModel.isBalanceHidden == true)
        #expect(viewModel.displayBalance == "* * * * * *")
        
        // Show balance again
        viewModel.toggleBalanceVisibility()
        #expect(viewModel.isBalanceHidden == false)
        #expect(viewModel.displayBalance == viewModel.formattedBalance)
    }
    
    @Test("HomeViewModel accepts custom initial balance and hidden state")
    func customInitialState() {
        let viewModel = HomeViewModel(initialBalance: 50_000, isBalanceHidden: true)
        
        #expect(viewModel.balance == 50_000)
        #expect(viewModel.isBalanceHidden == true)
        #expect(viewModel.displayBalance == "* * * * * *")
        #expect(viewModel.formattedBalance.contains("50,000"))
    }
    
    @Test("navigateToTopUp delegates to AppRouter")
    func navigateToTopUp() {
        let viewModel = HomeViewModel()
        let mockRouter = MockAppRouter()
        
        viewModel.navigateToTopUp(router: mockRouter)
        
        #expect(mockRouter.navigatedRoutes.count == 1)
        #expect(mockRouter.navigatedRoutes.first == .topUp)
    }
    
    @Test("navigateToHistory delegates to AppRouter")
    func navigateToHistory() {
        let viewModel = HomeViewModel()
        let mockRouter = MockAppRouter()
        
        viewModel.navigateToHistory(router: mockRouter)
        
        #expect(mockRouter.navigatedRoutes.count == 1)
        #expect(mockRouter.navigatedRoutes.first == .transactionHistory)
    }
}
