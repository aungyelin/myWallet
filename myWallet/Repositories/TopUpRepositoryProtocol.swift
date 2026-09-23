//
//  TopUpRepositoryProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData

@MainActor
public protocol TopUpRepositoryProtocol: AnyObject {
    
    func getPackages(for operatorName: String) async throws -> [PackageEntity]

    func getCachedPackages(for operatorName: String) throws -> [PackageEntity]

    func prefetchPackages() async

    func saveTransaction(_ transaction: TransactionHistory) throws

    func performRecharge(
        phone: String,
        operatorName: String,
        planTitle: String,
        amount: Double
    ) async throws -> TransactionHistory
    
}
