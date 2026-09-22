//
//  TopUpMainView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

/// Placeholder screen for Mobile Top-Up main entry.
struct TopUpMainView: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        VStack(spacing: LayoutMetrics.spacingLarge) {
            Spacer()
            
            Image(systemName: "iphone.gen3")
                .font(.system(size: LayoutMetrics.avatarSize))
                .foregroundStyle(.tint)
            
            Text(String(localized: "top_up_title"))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(String(localized: "placeholder_empty_screen"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button(action: {
                let params = TopUpCheckoutParams(
                    phone: "09250000000",
                    operatorType: .mpt,
                    planTitle: "10,000 Ks Top-Up",
                    amount: 10000
                )
                router?.navigate(to: .topUpDetail(params))
            }) {
                Label(String(localized: "action_proceed"), systemImage: "arrow.right")
                    .frame(maxWidth: .infinity)
                    .frame(height: LayoutMetrics.primaryButtonHeight)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, LayoutMetrics.spacingLarge)
            .frame(maxWidth: LayoutMetrics.maxContentWidth)
            
            Spacer()
        }
        .padding(LayoutMetrics.spacingStandard)
        .navigationTitle(String(localized: "top_up_title"))
    }
}

#Preview("TopUpMainView") {
    NavigationStack {
        TopUpMainView()
    }
}
