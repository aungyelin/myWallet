//
//  TopUpAmountTileView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import SwiftUI

struct TopUpAmountTileView: View {
    let amount: Double
    let action: () -> Void

    private var formattedNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: LayoutMetrics.spacingMicro) {
                Text(formattedNumber)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(Constants.Currency.symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.tint)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(AppColors.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(formattedNumber) \(Constants.Currency.symbol)")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("TopUpAmountTileView") {
    HStack {
        TopUpAmountTileView(amount: 1000) {}
        TopUpAmountTileView(amount: 5000) {}
        TopUpAmountTileView(amount: 10000) {}
    }
    .padding()
}
