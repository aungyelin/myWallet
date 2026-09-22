//
//  AppContainer.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData
import SwiftUI

/// Default application composition root holding shared dependencies and repositories.
@Observable
@MainActor
public final class AppContainer: AppContainerProtocol {
    public let modelContainer: ModelContainer
    public let networkService: MockNetworkServiceProtocol
    public let telecomRepository: TelecomRepositoryProtocol
    public let topUpRepository: TopUpRepositoryProtocol
    public let transactionRepository: TransactionRepositoryProtocol
    
    public init(
        modelContainer: ModelContainer,
        networkService: MockNetworkServiceProtocol? = nil,
        telecomRepository: TelecomRepositoryProtocol? = nil,
        topUpRepository: TopUpRepositoryProtocol? = nil,
        transactionRepository: TransactionRepositoryProtocol? = nil
    ) {
        self.modelContainer = modelContainer
        let network = networkService ?? MockNetworkService()
        self.networkService = network
        self.telecomRepository = telecomRepository ?? TelecomRepository(
            networkService: network,
            modelContext: modelContainer.mainContext
        )
        self.topUpRepository = topUpRepository ?? TopUpRepository(
            networkService: network,
            modelContext: modelContainer.mainContext
        )
        self.transactionRepository = transactionRepository ?? TransactionRepository(
            modelContext: modelContainer.mainContext
        )
    }

    /// Convenience factory creating an in-memory test/preview container with configurable latency.
    public static func createInMemory(latencyNanoseconds: UInt64 = 0) throws -> AppContainer {
        let container = try AppModelContainer.createInMemoryContainer()
        let network = MockNetworkService(latencyNanoseconds: latencyNanoseconds)
        return AppContainer(modelContainer: container, networkService: network)
    }
}

// MARK: - Environment Values Extension
private struct AppContainerKey: EnvironmentKey {
    @MainActor static var defaultValue: AppContainerProtocol? = nil
}

public extension EnvironmentValues {
    var appContainer: AppContainerProtocol? {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}
