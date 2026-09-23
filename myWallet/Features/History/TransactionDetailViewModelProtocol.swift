//
//  TransactionDetailViewModelProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation

@MainActor
public protocol TransactionDetailViewModelProtocol: AnyObject, Observable {
    
    var referenceNumber: String { get }
    var transaction: TransactionHistory? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var isCopied: Bool { get }
    var canRecharge: Bool { get }

    func loadTransaction()
    func copyReferenceNumber()
    func proceedToRecharge()
    
}
