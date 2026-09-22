//
//  ContentView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [TransactionHistory]

    var body: some View {
        NavigationStack {
            VStack(spacing: LayoutMetrics.spacingStandard) {
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: LayoutMetrics.avatarSize))
                    .foregroundStyle(.tint)

                Text(String(localized: "app_name"))
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(String(localized: "nav_top_up"))
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .padding(LayoutMetrics.spacingStandard)
            .navigationTitle(String(localized: "app_name"))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(try! AppModelContainer.createInMemoryContainer())
}
