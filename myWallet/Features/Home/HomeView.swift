//
//  HomeView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

/// Placeholder screen for Home dashboard.
struct HomeView: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        VStack(spacing: LayoutMetrics.spacingLarge) {
            Spacer()
            
            Image(systemName: "wallet.pass.fill")
                .font(.system(size: LayoutMetrics.avatarSize))
                .foregroundStyle(.tint)
            
            Text(String(localized: "nav_home"))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(String(localized: "placeholder_empty_screen"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: LayoutMetrics.spacingMedium) {
                Button(action: {
                    router?.navigate(to: .topUp)
                }) {
                    Label(String(localized: "btn_top_up"), systemImage: "iphone")
                        .frame(maxWidth: .infinity)
                        .frame(height: LayoutMetrics.primaryButtonHeight)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    router?.navigate(to: .transactionHistory)
                }) {
                    Label(String(localized: "btn_history"), systemImage: "clock.arrow.circlepath")
                        .frame(maxWidth: .infinity)
                        .frame(height: LayoutMetrics.primaryButtonHeight)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, LayoutMetrics.spacingLarge)
            .frame(maxWidth: LayoutMetrics.maxContentWidth)
            
            Spacer()
        }
        .padding(LayoutMetrics.spacingStandard)
        .navigationTitle(String(localized: "nav_home"))
    }
}

#Preview("HomeView - iPhone") {
    NavigationStack {
        HomeView()
    }
}
