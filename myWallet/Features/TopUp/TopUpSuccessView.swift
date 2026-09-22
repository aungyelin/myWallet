//
//  TopUpSuccessView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

struct TopUpSuccessView: View {
    let params: TopUpReceiptParams
    @Environment(\.appRouter) private var router
    @State private var isCheckmarkAnimated: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: LayoutMetrics.spacingLarge) {
                Spacer(minLength: LayoutMetrics.spacingMedium)
                
                // Animated Success Checkmark
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: LayoutMetrics.avatarSize))
                    .foregroundStyle(.green)
                    .scaleEffect(isCheckmarkAnimated ? 1.0 : 0.4)
                    .opacity(isCheckmarkAnimated ? 1.0 : 0.0)
                
                VStack(spacing: LayoutMetrics.spacingMicro) {
                    Text(String(localized: "top_up_success_title"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(String(localized: "top_up_success_message"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Transaction Receipt Card
                VStack(spacing: LayoutMetrics.spacingMedium) {
                    receiptRow(
                        title: String(localized: "top_up_receipt_reference"),
                        value: params.referenceNumber
                    )
                    
                    receiptRow(
                        title: String(localized: "top_up_receipt_time"),
                        value: AppDateFormatter.formatReceiptDate(params.timestamp)
                    )
                    
                    Divider()
                    
                    receiptRow(
                        title: String(localized: "top_up_detail_recipient"),
                        value: params.phone
                    )
                    
                    HStack(alignment: .center) {
                        Text(String(localized: "top_up_detail_operator"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack(spacing: LayoutMetrics.spacingSmall) {
                            TelecomLogoView(operatorType: params.operatorType, size: 20)
                            Text(params.operatorType.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    
                    receiptRow(
                        title: String(localized: "top_up_detail_plan"),
                        value: params.planTitle
                    )
                    
                    Divider()
                    
                    receiptRow(
                        title: String(localized: "top_up_detail_amount"),
                        value: CurrencyFormatter.format(params.amount)
                    )
                    
                    receiptRow(
                        title: String(localized: "top_up_fee"),
                        value: String(localized: "top_up_free_fee")
                    )
                }
                .padding(LayoutMetrics.spacingLarge)
                .background(AppColors.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )
                
                Spacer(minLength: LayoutMetrics.spacingSmall)
                
                // Back to Home Button
                Button(action: {
                    if router?.presentedCover != nil {
                        router?.dismissCover()
                    } else {
                        router?.popToRoot()
                    }
                }) {
                    Label(String(localized: "action_back_to_home"), systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: LayoutMetrics.primaryButtonHeight)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, LayoutMetrics.spacingSmall)
            }
            .padding(.horizontal, LayoutMetrics.screenHorizontalPadding)
            .padding(.vertical, LayoutMetrics.spacingStandard)
            .frame(maxWidth: LayoutMetrics.maxContentWidth)
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.screenBackground)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                isCheckmarkAnimated = true
            }
        }
    }
    
    @ViewBuilder
    private func receiptRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview("TopUpSuccessView") {
    NavigationStack {
        TopUpSuccessView(
            params: TopUpReceiptParams(
                referenceNumber: "20260923-839201",
                phone: "09253366392",
                operatorType: .mpt,
                planTitle: "Combo 1000MB (YouTube; TikTok; Telegram) (7 Days)",
                amount: 998
            )
        )
    }
}
