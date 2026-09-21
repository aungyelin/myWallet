//
//  myWalletApp.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import SwiftUI
import SwiftData

@main
struct myWalletApp: App {
    private let sharedModelContainer: ModelContainer

    init() {
        do {
            self.sharedModelContainer = try AppModelContainer.createContainer()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task(priority: .background) {
                    await preloadData()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    @MainActor
    private func preloadData() async {
        let networkService = MockNetworkService()
        let telecomRepo = TelecomRepository(
            networkService: networkService,
            modelContext: sharedModelContainer.mainContext
        )
        let topUpRepo = TopUpRepository(
            networkService: networkService,
            modelContext: sharedModelContainer.mainContext
        )

        async let prefixPreload: () = telecomRepo.prefetchPrefixes()
        async let packagePreload: () = topUpRepo.prefetchPackages()
        _ = await (prefixPreload, packagePreload)
    }
    
}
