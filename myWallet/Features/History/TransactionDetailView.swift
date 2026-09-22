//
//  TransactionDetailView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

/// Placeholder screen for Transaction Details.
struct TransactionDetailView: View {
    let referenceNumber: String
    
    @Environment(\.appRouter) private var router
    
    var body: some View {
        VStack(spacing: LayoutMetrics.spacingLarge) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: LayoutMetrics.avatarSize))
                .foregroundStyle(.tint)
            
            Text(String(localized: "transaction_detail_title"))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(referenceNumber)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(LayoutMetrics.spacingMedium)
            
            Button(action: {
                router?.pop()
            }) {
                Label(String(localized: "action_done"), systemImage: "arrow.left")
                    .frame(maxWidth: .infinity)
                    .frame(height: LayoutMetrics.primaryButtonHeight)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, LayoutMetrics.spacingLarge)
            .frame(maxWidth: LayoutMetrics.maxContentWidth)
            
            Spacer()
        }
        .padding(LayoutMetrics.spacingStandard)
        .navigationTitle(String(localized: "transaction_detail_title"))
    }
}

#Preview("TransactionDetailView") {
    NavigationStack {
        TransactionDetailView(referenceNumber: "20260922-839201")
    }
}
