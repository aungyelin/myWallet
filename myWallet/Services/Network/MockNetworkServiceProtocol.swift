//
//  MockNetworkServiceProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation

/// Defines network simulation endpoints for fetching telecom prefixes, package catalogs, transactions.
public protocol MockNetworkServiceProtocol: Sendable {
    
    func fetchTelecomPrefixes() async throws -> [TelecomPrefixDTO]
    func fetchPackages() async throws -> [PackageDTO]
    func submitTopUpRecharge(
        phone: String,
        operatorName: String,
        planTitle: String,
        amount: Double
    ) async throws -> TopUpRechargeResponseDTO
    
}
