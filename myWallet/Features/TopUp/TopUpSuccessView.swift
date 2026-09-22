//
//  TopUpSuccessView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

/// Placeholder screen for Mobile Top-Up success and receipt.
struct TopUpSuccessView: View {
    let params: TopUpReceiptParams
    
    @Environment(\.appRouter) private var router
    
    var body: some View {
        VStack(spacing: LayoutMetrics.spacingLarge) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: LayoutMetrics.avatarSize))
                .foregroundStyle(.green)
            
            Text(String(localized: "top_up_success_title"))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(String(localized: "top_up_success_message"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: LayoutMetrics.spacingSmall) {
                Text(params.referenceNumber)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(params.phone)
                    .font(.headline)
                Text(params.operatorType.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(Int(params.amount)) Ks")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.tint)
            }
            .padding(LayoutMetrics.spacingMedium)
            
            Button(action: {
                if router?.presentedCover != nil {
                    router?.dismissCover()
                } else {
                    router?.popToRoot()
                }
            }) {
                Label(String(localized: "action_back_to_home"), systemImage: "house")
                    .frame(maxWidth: .infinity)
                    .frame(height: LayoutMetrics.primaryButtonHeight)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, LayoutMetrics.spacingLarge)
            .frame(maxWidth: LayoutMetrics.maxContentWidth)
            
            Spacer()
        }
        .padding(LayoutMetrics.spacingStandard)
        .navigationTitle(String(localized: "top_up_success_title"))
        .navigationBarBackButtonHidden(true)
    }
}

#Preview("TopUpSuccessView") {
    NavigationStack {
        TopUpSuccessView(
            params: TopUpReceiptParams(
                referenceNumber: "TXN-20260922-839201",
                phone: "09250000000",
                operatorType: .mpt,
                planTitle: "10,000 Ks Top-Up",
                amount: 10000
            )
        )
    }
}
