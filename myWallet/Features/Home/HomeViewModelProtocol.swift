//
//  HomeViewModelProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation

@MainActor
public protocol HomeViewModelProtocol: AnyObject {
    
    var isBalanceHidden: Bool { get }
    
    var balance: Double { get }
    
    var formattedBalance: String { get }
    
    var displayBalance: String { get }
    
    func toggleBalanceVisibility()
    
    func navigateToTopUp(router: (any AppRouterProtocol)?)
    
    func navigateToHistory(router: (any AppRouterProtocol)?)
    
}
