//
//  TelecomRepositoryProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData

@MainActor
public protocol TelecomRepositoryProtocol: AnyObject {
    
    func detectOperator(for rawPhoneNumber: String) async throws -> TelecomPrefixEntity?

    func getPrefixes() async throws -> [TelecomPrefixEntity]

    func prefetchPrefixes() async
    
}
