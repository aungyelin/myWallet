//
//  TransactionDetailView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

@MainActor
struct TransactionDetailView<VM: TransactionDetailViewModelProtocol>: View {
    @Environment(\.appContainer) private var appContainer
    let referenceNumber: String
    private let customViewModel: VM?

    init(viewModel: VM) {
        self.referenceNumber = viewModel.referenceNumber
        self.customViewModel = viewModel
    }

    var body: some View {
        if let customViewModel {
            TransactionDetailContentView(viewModel: customViewModel)
        } else if let appContainer {
            TransactionDetailContainerLoadedView(referenceNumber: referenceNumber, container: appContainer)
        } else {
            ProgressView()
        }
    }
}

extension TransactionDetailView where VM == TransactionDetailViewModel {
    @MainActor
    init(referenceNumber: String) {
        self.referenceNumber = referenceNumber
        self.customViewModel = nil
    }
}

@MainActor
private struct TransactionDetailContainerLoadedView: View {
    @State private var viewModel: TransactionDetailViewModel

    init(referenceNumber: String, container: any AppContainerProtocol) {
        _viewModel = State(wrappedValue: TransactionDetailViewModel(
            referenceNumber: referenceNumber,
            transactionRepository: container.transactionRepository,
            router: container.appRouter
        ))
    }

    var body: some View {
        TransactionDetailContentView(viewModel: viewModel)
    }
}

@MainActor
private struct TransactionDetailContentView<VM: TransactionDetailViewModelProtocol>: View {
    @Bindable var viewModel: VM
    @Environment(\.appRouter) private var router

    var body: some View {
        ScrollView {
            VStack(spacing: LayoutMetrics.spacingLarge) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let transaction = viewModel.transaction {
                    // Header Receipt Summary
                    VStack(spacing: LayoutMetrics.spacingMedium) {
                        iconView(for: transaction)
                            .frame(width: 64, height: 64)

                        VStack(spacing: 4) {
                            Text("- \(CurrencyFormatter.format(transaction.amount))")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.primary)

                            Text(transaction.parsedType.localizedTitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        // Status Badge
                        HStack(spacing: 4) {
                            Image(systemName: transaction.parsedStatus.systemIconName)
                                .font(.caption)
                            Text(transaction.parsedStatus.localizedTitle)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(transaction.parsedStatus.statusColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(transaction.parsedStatus.statusColor.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LayoutMetrics.spacingLarge)
                    .background(AppColors.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusLarge))
                    .overlay(
                        RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusLarge)
                            .stroke(AppColors.cardBorder, lineWidth: 1)
                    )

                    // Key-Value Details Breakdown Card
                    VStack(spacing: LayoutMetrics.spacingMedium) {
                        // Reference Number with Copy Action
                        HStack {
                            Text(AppLocalization.string("detail_reference"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            HStack(spacing: LayoutMetrics.spacingSmall) {
                                Text(transaction.referenceNumber)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)

                                Button(action: {
                                    viewModel.copyReferenceNumber()
                                }) {
                                    Image(systemName: viewModel.isCopied ? "checkmark" : "doc.on.doc")
                                        .font(.caption)
                                        .foregroundStyle(viewModel.isCopied ? Color.green : Color.accentColor)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(AppLocalization.string("action_copy"))
                            }
                        }

                        Divider()

                        // Date & Time (International Gregorian Calendar)
                        detailRow(
                            title: AppLocalization.string("detail_date"),
                            value: AppDateFormatter.formatDateTime(transaction.date)
                        )

                        Divider()

                        // Recipient / Mobile Number
                        if let mobile = transaction.mobileNumber {
                            detailRow(
                                title: AppLocalization.string("detail_recipient"),
                                value: mobile
                            )
                            Divider()
                        } else if !transaction.counterparty.isEmpty {
                            detailRow(
                                title: AppLocalization.string("detail_recipient"),
                                value: transaction.recipientName ?? transaction.counterparty
                            )
                            Divider()
                        }

                        // Operator (if Top-Up)
                        if transaction.parsedType == .topUp, transaction.operatorType != .unknown {
                            HStack {
                                Text(AppLocalization.string("filter_operator"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                TelecomBadgeView(operatorType: transaction.operatorType, style: .cardBadge)
                            }
                            Divider()
                        }

                        // Plan / Package Description
                        if let plan = transaction.planDetails {
                            detailRow(
                                title: AppLocalization.string("detail_plan"),
                                value: plan
                            )
                            Divider()
                        }

                        // Transaction Fee
                        detailRow(
                            title: AppLocalization.string("detail_fee"),
                            value: "0 \(Constants.Currency.symbol)"
                        )

                        // Remarks (if any)
                        if let remark = transaction.remark, !remark.isEmpty {
                            Divider()
                            detailRow(
                                title: AppLocalization.string("detail_remark"),
                                value: remark
                            )
                        }
                    }
                    .padding(LayoutMetrics.spacingStandard)
                    .background(AppColors.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusLarge))
                    .overlay(
                        RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusLarge)
                            .stroke(AppColors.cardBorder, lineWidth: 1)
                    )

                    // Copied Toast Notification
                    if viewModel.isCopied {
                        Text(AppLocalization.string("copied_to_clipboard"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    }

                    // Recharge Quick Action (Top-Up only)
                    if viewModel.canRecharge {
                        Button(action: {
                            viewModel.proceedToRecharge()
                        }) {
                            HStack(spacing: LayoutMetrics.spacingSmall) {
                                Image(systemName: "arrow.clockwise")
                                Text(AppLocalization.string("action_recharge"))
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: LayoutMetrics.primaryButtonHeight)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium))
                        }
                        .padding(.top, LayoutMetrics.spacingSmall)
                        .accessibilityLabel(AppLocalization.string("action_recharge"))
                        .accessibilityHint(AppLocalization.string("action_recharge_hint"))
                        .accessibilityAddTraits(.isButton)
                    }

                } else {
                    // Not Found Error State
                    VStack(spacing: LayoutMetrics.spacingMedium) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text(viewModel.errorMessage ?? "Transaction not found.")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Button(action: { router?.pop() }) {
                            Text(AppLocalization.string("action_done"))
                                .font(.headline)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                }
            }
            .padding(LayoutMetrics.screenHorizontalPadding)
            .frame(maxWidth: LayoutMetrics.maxContentWidth)
            .frame(maxWidth: .infinity)
        }
        .background(AppColors.screenBackground)
        .navigationTitle(AppLocalization.string("transaction_detail_title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
    }

    @ViewBuilder
    private func iconView(for transaction: TransactionHistory) -> some View {
        switch transaction.parsedType {
        case .topUp:
            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .overlay(
                    Image(systemName: transaction.parsedType.systemIconName)
                        .foregroundStyle(Color.accentColor)
                        .font(.system(size: 28, weight: .semibold))
                )
        case .transfer:
            Circle()
                .fill(Color.blue.opacity(0.12))
                .overlay(
                    Image(systemName: transaction.parsedType.systemIconName)
                        .foregroundStyle(Color.blue)
                        .font(.system(size: 28, weight: .semibold))
                )
        case .payment:
            Circle()
                .fill(Color.purple.opacity(0.12))
                .overlay(
                    Image(systemName: transaction.parsedType.systemIconName)
                        .foregroundStyle(Color.purple)
                        .font(.system(size: 28, weight: .semibold))
                )
        }
    }
}

#Preview("TransactionDetailView - iPhone") {
    NavigationStack {
        TransactionDetailView(referenceNumber: "20260920-00109")
    }
}

#Preview("TransactionDetailView - iPad", traits: .landscapeLeft) {
    NavigationStack {
        TransactionDetailView(referenceNumber: "20260920-00109")
    }
}
