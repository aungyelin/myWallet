//
//  TelecomBadgeView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import SwiftUI

struct TelecomBadgeView: View {
    let operatorType: TelecomOperator
    var style: Style = .textTag

    enum Style {
        case textTag
        case cardBadge
    }

    var body: some View {
        switch style {
        case .textTag:
            HStack(spacing: LayoutMetrics.spacingSmall) {
                TelecomLogoView(operatorType: operatorType, size: 18)

                Text(operatorType.displayName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(operatorType.brandColor)
            }
            .frame(height: 24)
            .accessibilityLabel(operatorType.displayName)

        case .cardBadge:
            HStack(spacing: LayoutMetrics.spacingSmall) {
                TelecomLogoView(operatorType: operatorType, size: 22)

                Text(operatorType.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .padding(.leading, LayoutMetrics.spacingSmall)
            .padding(.trailing, LayoutMetrics.spacingMedium)
            .padding(.vertical, 3)
            .background(AppColors.cardSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
            .accessibilityLabel(operatorType.displayName)
        }
    }
}

#Preview("TelecomBadgeView - Styles") {
    VStack(spacing: 16) {
        TelecomBadgeView(operatorType: .mpt, style: .textTag)
        TelecomBadgeView(operatorType: .atom, style: .textTag)
        TelecomBadgeView(operatorType: .u9, style: .cardBadge)
        TelecomBadgeView(operatorType: .mytel, style: .cardBadge)
    }
    .padding()
}
