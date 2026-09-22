//
//  PackageCardView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import SwiftUI

struct PackageCardView: View {
    let package: PackageEntity
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                Text(package.name)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Spacer(minLength: LayoutMetrics.spacingMicro)

                HStack(alignment: .center) {
                    Text(CurrencyFormatter.format(package.amount))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.tint)

                    Spacer()

                    if package.isPopular {
                        Text(String(localized: "top_up_badge_hot"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusSmall))
                    }
                }
            }
            .padding(LayoutMetrics.spacingMedium)
            .frame(maxWidth: .infinity, minHeight: 94, alignment: .topLeading)
            .background(AppColors.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(package.name), \(CurrencyFormatter.format(package.amount))\(package.isPopular ? ", Hot" : "")")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("PackageCardView - Standard & Hot") {
    HStack {
        PackageCardView(
            package: PackageEntity(
                id: "1",
                operatorName: "MPT",
                category: "Data",
                packGroup: "A Kyite Kyi",
                name: "Combo 1000MB (YouTube; TikTok; Telegram) (7 Days)",
                packageDescription: "Test",
                amount: 998,
                validityDays: 7,
                validityText: "7 Days",
                isPopular: false
            )
        ) {}

        PackageCardView(
            package: PackageEntity(
                id: "2",
                operatorName: "MPT",
                category: "Data",
                packGroup: "Data Carry Plus",
                name: "263MB (30 Days)",
                packageDescription: "Test",
                amount: 999,
                validityDays: 30,
                validityText: "30 Days",
                isPopular: true
            )
        ) {}
    }
    .padding()
}
