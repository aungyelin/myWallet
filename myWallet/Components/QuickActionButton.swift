//
//  QuickActionButton.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

struct QuickActionButton: View {
    let title: String
    let iconName: String
    let isSystemIcon: Bool
    let tintColor: Color
    let action: () -> Void
    
    init(
        title: String,
        iconName: String,
        isSystemIcon: Bool = true,
        tintColor: Color = .accentColor,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.isSystemIcon = isSystemIcon
        self.tintColor = tintColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: LayoutMetrics.spacingSmall) {
                ZStack {
                    Circle()
                        .fill(tintColor.opacity(0.12))
                        .frame(width: LayoutMetrics.actionCircleSize, height: LayoutMetrics.actionCircleSize)
                    
                    if isSystemIcon {
                        Image(systemName: iconName)
                            .font(.system(size: LayoutMetrics.actionCircleIconSize, weight: .semibold))
                            .foregroundStyle(tintColor)
                    } else {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: LayoutMetrics.actionCircleIconSize, height: LayoutMetrics.actionCircleIconSize)
                            .foregroundStyle(tintColor)
                    }
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(LayoutMetrics.actionLabelMaxLines)
                    .frame(maxWidth: .infinity)
                    .frame(height: LayoutMetrics.actionLabelReservedHeight, alignment: .top)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("QuickActionButton - Alignment Comparison") {
    HStack(alignment: .top, spacing: LayoutMetrics.spacingMedium) {
        QuickActionButton(
            title: String(localized: "btn_top_up"),
            iconName: "iphone.gen3",
            action: {}
        )
        QuickActionButton(
            title: String(localized: "btn_history"),
            iconName: "clock.arrow.circlepath",
            action: {}
        )
        QuickActionButton(
            title: String(localized: "top_up_title"),
            iconName: "qrcode.viewfinder",
            action: {}
        )
        QuickActionButton(
            title: String(localized: "action_recharge"),
            iconName: "viewfinder",
            action: {}
        )
    }
    .padding()
}
