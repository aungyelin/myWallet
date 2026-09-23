//
//  ProfileCardView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

struct ProfileCardView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: LayoutMetrics.spacingLarge) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: LayoutMetrics.actionCircleSize))
                .foregroundStyle(Color.accentColor)
                .frame(width: LayoutMetrics.actionCircleSize, height: LayoutMetrics.actionCircleSize)
            
            VStack(alignment: .leading, spacing: LayoutMetrics.spacingMicro) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(LayoutMetrics.balanceCardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: LayoutMetrics.balanceCardHeight)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
    }
}

#Preview("ProfileCardView") {
    VStack {
        ProfileCardView(
            title: "Ye Lin Aung",
            subtitle: "myWallet"
        )
        .padding(.top)
        
        Spacer()
    }
    .background(AppColors.screenBackground)
}
