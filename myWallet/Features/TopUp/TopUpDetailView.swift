//
//  TopUpDetailView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

/// Placeholder screen for Mobile Top-Up checkout and confirmation.
struct TopUpDetailView: View {
    let params: TopUpCheckoutParams
    
    @Environment(\.appRouter) private var router
    
    var body: some View {
        VStack(spacing: LayoutMetrics.spacingLarge) {
            Spacer()
            
            Image(systemName: "checkmark.shield")
                .font(.system(size: LayoutMetrics.avatarSize))
                .foregroundStyle(.tint)
            
            Text(String(localized: "top_up_detail_title"))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: LayoutMetrics.spacingSmall) {
                Text(params.phone)
                    .font(.headline)
                Text(params.operatorType.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(params.planTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(Int(params.amount)) Ks")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tint)
            }
            .padding(LayoutMetrics.spacingMedium)
            
            Button(action: {
                let receiptParams = TopUpReceiptParams(
                    referenceNumber: ReferenceNumberGenerator.generate(),
                    phone: params.phone,
                    operatorType: params.operatorType,
                    planTitle: params.planTitle,
                    amount: params.amount,
                    fee: params.fee
                )
                router?.navigate(to: .topUpSuccess(receiptParams))
            }) {
                Label(String(localized: "btn_simulate_checkout"), systemImage: "creditcard")
                    .frame(maxWidth: .infinity)
                    .frame(height: LayoutMetrics.primaryButtonHeight)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, LayoutMetrics.spacingLarge)
            .frame(maxWidth: LayoutMetrics.maxContentWidth)
            
            Spacer()
        }
        .padding(LayoutMetrics.spacingStandard)
        .navigationTitle(String(localized: "top_up_detail_title"))
    }
}

#Preview("TopUpDetailView") {
    NavigationStack {
        TopUpDetailView(
            params: TopUpCheckoutParams(
                phone: "09250000000",
                operatorType: .mpt,
                planTitle: "10,000 Ks Top-Up",
                amount: 10000
            )
        )
    }
}
