//
//  TransactionHistoryView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

struct TransactionHistoryView<VM: TransactionHistoryViewModelProtocol>: View {
    @Environment(\.appContainer) private var appContainer
    private let customViewModel: VM?

    init(viewModel: VM) {
        self.customViewModel = viewModel
    }

    var body: some View {
        if let customViewModel {
            TransactionHistoryContentView(viewModel: customViewModel)
        } else if let appContainer {
            TransactionHistoryContainerLoadedView(container: appContainer)
        } else {
            ProgressView()
        }
    }
}

extension TransactionHistoryView where VM == TransactionHistoryViewModel {
    init() {
        self.customViewModel = nil
    }
}

private struct TransactionHistoryContainerLoadedView: View {
    @State private var viewModel: TransactionHistoryViewModel

    init(container: any AppContainerProtocol) {
        _viewModel = State(wrappedValue: TransactionHistoryViewModel(
            transactionRepository: container.transactionRepository
        ))
    }

    var body: some View {
        TransactionHistoryContentView(viewModel: viewModel)
    }
}

private struct TransactionHistoryContentView<VM: TransactionHistoryViewModelProtocol>: View {
    @Bindable var viewModel: VM
    @Environment(\.appRouter) private var router
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @FocusState private var isSearchFocused: Bool

    private var contentMaxWidth: CGFloat {
        horizontalSizeClass == .regular ? 900 : .infinity
    }

    private var isPhonePortrait: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }

    var body: some View {
        VStack(spacing: LayoutMetrics.spacingMedium) {
            // Search & Filter Header
            VStack(spacing: LayoutMetrics.spacingMedium) {
                // Search Field
                HStack(spacing: LayoutMetrics.spacingSmall) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField(
                        String(localized: "transaction_history_search_placeholder"),
                        text: $viewModel.searchQuery
                    )
                    .font(.body)
                    .focused($isSearchFocused)
                    .onChange(of: viewModel.searchQuery) { _, newValue in
                        Task {
                            await viewModel.onSearchQueryChanged(newValue)
                        }
                    }

                    if !viewModel.searchQuery.isEmpty {
                        Button(action: {
                            viewModel.searchQuery = ""
                            Task {
                                await viewModel.onSearchQueryChanged("")
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(LayoutMetrics.spacingMedium)
                .background(AppColors.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium))
                .overlay(
                    RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )

                // Quick Operator Filter & Filter Sheet Button
                HStack(spacing: LayoutMetrics.spacingSmall) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: LayoutMetrics.spacingSmall) {
                            // "All" option
                            let isAllSelected = viewModel.selectedOperator == nil
                            Button(action: {
                                viewModel.selectOperator(nil)
                            }) {
                                Text(String(localized: "filter_all"))
                                    .font(.subheadline)
                                    .fontWeight(isAllSelected ? .semibold : .regular)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(isAllSelected ? Color.accentColor : AppColors.cardSurface)
                                    .foregroundStyle(isAllSelected ? Color.white : Color.primary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(isAllSelected ? Color.clear : AppColors.cardBorder, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)

                            // Dynamic available operators
                            ForEach(viewModel.availableOperators, id: \.self) { op in
                                let isSelected = viewModel.selectedOperator == op
                                Button(action: {
                                    viewModel.selectOperator(op)
                                }) {
                                    Text(op.displayName)
                                        .font(.subheadline)
                                        .fontWeight(isSelected ? .semibold : .regular)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? Color.accentColor : AppColors.cardSurface)
                                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(isSelected ? Color.clear : AppColors.cardBorder, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Divider()
                        .frame(height: 24)

                    // Open Full Filter Sheet
                    Button(action: {
                        viewModel.isFilterSheetPresented = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.body)
                            if viewModel.hasActiveFilters {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .foregroundStyle(viewModel.hasActiveFilters ? Color.accentColor : Color.secondary)
                        .padding(8)
                        .background(AppColors.cardSurface)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(AppColors.cardBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "filter_title"))
                }

                // Active Filters Chips (Removable)
                if viewModel.hasActiveFilters {
                    HStack(spacing: LayoutMetrics.spacingSmall) {
                        if let status = viewModel.selectedStatus {
                            activeChip(title: status.localizedTitle) {
                                viewModel.selectStatus(nil)
                            }
                        }
                        if viewModel.selectedDateFilter != .all {
                            activeChip(title: viewModel.selectedDateFilter.localizedTitle) {
                                viewModel.selectDateFilter(.all)
                            }
                        }
                        Spacer()
                        Button(String(localized: "filter_reset")) {
                            viewModel.resetFilters()
                        }
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, LayoutMetrics.screenHorizontalPadding)
            .padding(.vertical, LayoutMetrics.spacingSmall)
            .background(AppColors.screenBackground)

            // Content List or Empty State
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.transactions.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.transactions.enumerated()), id: \.element.id) { index, transaction in
                            Button(action: {
                                viewModel.selectTransaction(transaction, router: router)
                            }) {
                                TransactionRowView(transaction: transaction)
                                    .padding(.horizontal, LayoutMetrics.spacingStandard)
                                    .padding(.vertical, LayoutMetrics.spacingMedium)
                            }
                            .buttonStyle(.plain)

                            if index < viewModel.transactions.count - 1 {
                                Divider()
                                    .padding(.leading, 80)
                            }
                        }
                    }
                    .background(AppColors.cardSurface)
                    .clipShape(RoundedRectangle(
                        cornerRadius: isPhonePortrait ? 0 : LayoutMetrics.cornerRadiusLarge,
                        style: .continuous
                    ))
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: isPhonePortrait ? 0 : LayoutMetrics.cornerRadiusLarge,
                            style: .continuous
                        )
                            .stroke(AppColors.cardBorder, lineWidth: isPhonePortrait ? 0 : 1)
                    )
                    .shadow(
                        color: .black.opacity(isPhonePortrait ? 0 : 0.04),
                        radius: isPhonePortrait ? 0 : 12,
                        y: isPhonePortrait ? 0 : 4
                    )
                    .padding(.horizontal, isPhonePortrait ? 0 : LayoutMetrics.screenHorizontalPadding)
                    .padding(.bottom, LayoutMetrics.spacingLarge)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .frame(maxWidth: contentMaxWidth)
        .frame(maxWidth: .infinity)
        .background(AppColors.screenBackground)
        .navigationTitle(String(localized: "transaction_history_title"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.isFilterSheetPresented) {
            TransactionFilterSheetView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadTransactions()
        }
    }

    private func activeChip(title: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .foregroundStyle(Color.accentColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.12))
        .clipShape(Capsule())
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: LayoutMetrics.spacingMedium) {
            Spacer()

            Image(systemName: viewModel.hasActiveFilters || !viewModel.searchQuery.isEmpty ? "magnifyingglass" : "clock.arrow.circlepath")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text(viewModel.hasActiveFilters || !viewModel.searchQuery.isEmpty ? String(localized: "history_no_search_results_title") : String(localized: "history_empty_title"))
                .font(.headline)
                .foregroundStyle(.primary)

            Text(viewModel.hasActiveFilters || !viewModel.searchQuery.isEmpty ? String(localized: "history_no_search_results_description") : String(localized: "history_empty_description"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LayoutMetrics.spacingLarge)

            if viewModel.hasActiveFilters || !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.resetFilters()
                }) {
                    Text(String(localized: "filter_reset"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, LayoutMetrics.spacingSmall)
            } else {
                Button(action: {
                    router?.navigate(to: .topUp)
                }) {
                    Text(String(localized: "btn_top_up"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, LayoutMetrics.spacingSmall)
            }

            Spacer()
        }
        .padding(LayoutMetrics.spacingLarge)
    }
}

#Preview("TransactionHistoryView - iPhone") {
    NavigationStack {
        TransactionHistoryView()
    }
}

#Preview("TransactionHistoryView - iPad", traits: .landscapeLeft) {
    NavigationStack {
        TransactionHistoryView()
    }
}
