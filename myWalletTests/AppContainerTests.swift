//
//  AppContainerTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Testing
import Foundation
import SwiftData
@testable import myWallet

@Suite("AppContainer Tests")
@MainActor
struct AppContainerTests {
    
    @Test("AppContainer initializes shared repositories with in-memory container")
    func containerInitialization() throws {
        let modelContainer = try AppModelContainer.createInMemoryContainer()
        let networkService = MockNetworkService(latencyNanoseconds: 0)
        
        let container = AppContainer(
            modelContainer: modelContainer,
            networkService: networkService
        )
        
        #expect(container.telecomRepository != nil)
        #expect(container.topUpRepository != nil)
        #expect(container.transactionRepository != nil)
        #expect(container.networkService != nil)
        #expect(container.themeManager != nil)
        #expect(container.appRouter != nil)
        #expect(container.modelContainer === modelContainer)
    }

    @Test("AppContainer conforms to AppContainerProtocol contract")
    func protocolConformance() throws {
        let modelContainer = try AppModelContainer.createInMemoryContainer()
        let container: any AppContainerProtocol = AppContainer(modelContainer: modelContainer)
        
        #expect(container.modelContainer != nil)
        #expect(container.telecomRepository != nil)
        #expect(container.topUpRepository != nil)
        #expect(container.transactionRepository != nil)
        #expect(container.themeManager != nil)
        #expect(container.appRouter != nil)
    }

    @Test("createInMemory factory creates valid preview container with zero latency")
    func inMemoryFactory() throws {
        let container = try AppContainer.createInMemory(latencyNanoseconds: 0)
        #expect(container.telecomRepository != nil)
        #expect(container.topUpRepository != nil)
        #expect(container.transactionRepository != nil)
        #expect(container.themeManager != nil)
        #expect(container.appRouter != nil)
        #expect(container.modelContainer != nil)
    }
    
}
