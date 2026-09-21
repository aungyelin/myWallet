//
//  AppModelContainer.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData

public enum AppModelContainer {
    
    public static let schema = Schema([
        TransactionHistory.self,
        TelecomPrefixEntity.self,
        PackageEntity.self
    ])

    public static func createContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    public static func createInMemoryContainer() throws -> ModelContainer {
        try createContainer(inMemory: true)
    }
    
}
