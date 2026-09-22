//
//  TransactionHistoryView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

/// Placeholder screen for Transaction History.
struct TransactionHistoryView: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        VStack(spacing: LayoutMetrics.spacingLarge) {
            Spacer()
            
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: LayoutMetrics.avatarSize))
                .foregroundStyle(.tint)
            
            Text(String(localized: "transaction_history_title"))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(String(localized: "placeholder_empty_screen"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button(action: {
                router?.navigate(to: .transactionDetail(referenceNumber: "20260922-839201"))
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
        .navigationTitle(String(localized: "transaction_history_title"))
    }
}

#Preview("TransactionHistoryView") {
    NavigationStack {
        TransactionHistoryView()
    }
}
