//
//  TransactionRowView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import SwiftUI

public struct TransactionRowView: View {
    public let item: TransactionHistory

    public init(transaction: TransactionHistory) {
        self.item = transaction
    }

    public init(item: TransactionHistory) {
        self.item = item
    }

    public var body: some View {
        HStack(alignment: .top, spacing: LayoutMetrics.spacingMedium) {
            // Left: Operator or Category Icon
            iconView
                .frame(width: 48, height: 48)

            // Center: Title, Subtitle, and Formatted Timestamp
            VStack(alignment: .leading, spacing: 3) {
                Text(titleText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let subtitle = subtitleText {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(AppDateFormatter.formatDateTime(item.date))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            // Right: Formatted Amount & Status Capsule
            VStack(alignment: .trailing, spacing: 4) {
                Text(amountText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 4) {
                    Image(systemName: item.parsedStatus.systemIconName)
                        .font(.system(size: 8, weight: .bold))
                    Text(item.parsedStatus.localizedTitle)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(item.parsedStatus.statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(item.parsedStatus.statusColor.opacity(0.12))
                .clipShape(Capsule())
                .fixedSize(horizontal: true, vertical: false)
            }
            .frame(minWidth: 84, alignment: .trailing)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(titleText), \(amountText), \(item.parsedStatus.localizedTitle)")
    }

    @ViewBuilder
    private var iconView: some View {
        switch item.parsedType {
        case .topUp:
            TelecomLogoView(operatorType: item.operatorType, size: 40)
        case .transfer:
            Circle()
                .fill(Color.blue.opacity(0.12))
                .overlay(
                    Image(systemName: item.parsedType.systemIconName)
                        .foregroundStyle(Color.blue)
                        .font(.system(size: 18, weight: .semibold))
                )
        case .payment:
            Circle()
                .fill(Color.purple.opacity(0.12))
                .overlay(
                    Image(systemName: item.parsedType.systemIconName)
                        .foregroundStyle(Color.purple)
                        .font(.system(size: 18, weight: .semibold))
                )
        }
    }

    private var titleText: String {
        switch item.parsedType {
        case .topUp:
            return item.planDetails ?? item.operatorName ?? item.parsedType.localizedTitle
        case .transfer:
            return item.recipientName ?? item.counterparty
        case .payment:
            return item.recipientName ?? item.counterparty
        }
    }

    private var subtitleText: String? {
        switch item.parsedType {
        case .topUp:
            return item.mobileNumber
        case .transfer:
            return item.counterparty
        case .payment:
            return item.remark ?? item.parsedType.localizedTitle
        }
    }

    private var amountText: String {
        "- \(CurrencyFormatter.format(item.amount))"
    }
}
