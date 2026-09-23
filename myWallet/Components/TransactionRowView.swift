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
        HStack(spacing: LayoutMetrics.spacingMedium) {
            // Left: Operator or Category Icon
            iconView
                .frame(width: 44, height: 44)

            // Center: Title, Subtitle, and Formatted Timestamp
            VStack(alignment: .leading, spacing: 3) {
                Text(titleText)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if let subtitle = subtitleText {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(AppDateFormatter.formatDateTime(item.date))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: LayoutMetrics.spacingSmall)

            // Right: Formatted Amount & Status Capsule
            VStack(alignment: .trailing, spacing: 4) {
                Text(amountText)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    Image(systemName: item.parsedStatus.systemIconName)
                        .font(.system(size: 9, weight: .bold))
                    Text(item.parsedStatus.localizedTitle)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundStyle(item.parsedStatus.statusColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(item.parsedStatus.statusColor.opacity(0.12))
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, LayoutMetrics.spacingSmall)
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
