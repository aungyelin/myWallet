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
}
