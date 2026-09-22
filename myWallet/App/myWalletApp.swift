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
    private let container: AppContainer

    init() {
        do {
            let modelContainer = try AppModelContainer.createContainer()
            self.container = AppContainer(modelContainer: modelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(router: container.router)
                .environment(container)
                .environment(\.appContainer, container)
                .environment(container.router)
                .environment(\.appRouter, container.router)
                .environment(ThemeManager.shared)
                .environment(\.themeManager, ThemeManager.shared)
                .task(priority: .background) {
                    await preloadData()
                }
        }
        .modelContainer(container.modelContainer)
    }

    @MainActor
    private func preloadData() async {
        async let prefixPreload: () = container.telecomRepository.prefetchPrefixes()
        async let packagePreload: () = container.topUpRepository.prefetchPackages()
        _ = await (prefixPreload, packagePreload)
    }
}
