//
//  BalanceCardView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

struct BalanceCardView: View {
    let title: String
    let formattedBalance: String
    let isHidden: Bool
    let onToggleVisibility: () -> Void
    
    private let hiddenMask = String(localized: "home_balance_hidden_mask")
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutMetrics.spacingMedium) {
            // Row 1: Title and Visibility Toggle Button (Fixed 28pt height)
            HStack(alignment: .center) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onToggleVisibility()
                    }
                }) {
                    Image(systemName: isHidden ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: LayoutMetrics.iconSizeSmall, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(LayoutMetrics.spacingMicro)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(
                    isHidden ? String(localized: "home_balance_show") : String(localized: "home_balance_hide")
                )
                .accessibilityHint(
                    isHidden ? String(localized: "home_balance_show") : String(localized: "home_balance_hide")
                )
            }
            .frame(height: 28)
            
            // Row 2: Balance Display (Fixed 36pt height, leading-aligned)
            HStack(alignment: .center) {
                Text(isHidden ? hiddenMask : formattedBalance)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Spacer()
            }
            .frame(height: LayoutMetrics.balanceAmountHeight, alignment: .leading)
        }
        .padding(LayoutMetrics.balanceCardPadding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: LayoutMetrics.balanceCardHeight, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius, style: .continuous)
                .fill(AppColors.cardSurface)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                .overlay {
                    RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius, style: .continuous)
                        .strokeBorder(AppColors.cardBorder, lineWidth: 1)
                }
        }
        .padding(.horizontal, LayoutMetrics.screenHorizontalPadding)
        .frame(maxWidth: LayoutMetrics.maxContentWidth)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            String(format: String(localized: "home_balance_accessibility_format"), isHidden ? hiddenMask : formattedBalance)
        )
    }
}

#Preview("BalanceCardView - Visible") {
    VStack {
        BalanceCardView(
            title: String(localized: "home_balance_title"),
            formattedBalance: "1,250,000 \(String(localized: "home_balance_currency"))",
            isHidden: false,
            onToggleVisibility: {}
        )
        .padding(.top)
        
        Spacer()
    }
    .background(AppColors.screenBackground)
}

#Preview("BalanceCardView - Hidden") {
    VStack {
        BalanceCardView(
            title: String(localized: "home_balance_title"),
            formattedBalance: "1,250,000 \(String(localized: "home_balance_currency"))",
            isHidden: true,
            onToggleVisibility: {}
        )
        .padding(.top)
        
        Spacer()
    }
    .background(AppColors.screenBackground)
}
