//
//  TelecomLogoView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import SwiftUI

struct TelecomLogoView: View {
    let operatorType: TelecomOperator
    var size: CGFloat = 24

    var body: some View {
        ZStack {
            // White circular background container
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .shadow(color: Color.black.opacity(0.06), radius: 1, x: 0, y: 1)

            if let assetName = operatorType.logoAssetName {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: size, height: size)
            } else {
                // Fallback for unknown operator or missing asset
                Image(systemName: operatorType.logoImageName)
                    .font(.system(size: size * 0.5, weight: .semibold))
                    .foregroundStyle(operatorType.brandColor)
            }
        }
        .frame(width: size, height: size)
        .overlay(
            Circle()
                .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
        )
        .accessibilityHidden(true)
    }
}

#Preview("TelecomLogoView - All Operators") {
    HStack(spacing: 16) {
        TelecomLogoView(operatorType: .mpt, size: 36)
        TelecomLogoView(operatorType: .atom, size: 36)
        TelecomLogoView(operatorType: .u9, size: 36)
        TelecomLogoView(operatorType: .mytel, size: 36)
        TelecomLogoView(operatorType: .unknown, size: 36)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
