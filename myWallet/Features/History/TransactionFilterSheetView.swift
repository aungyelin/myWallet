//
//  TransactionFilterSheetView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import SwiftUI

struct TransactionFilterSheetView<VM: TransactionHistoryViewModelProtocol>: View {
    @Bindable var viewModel: VM
    @Environment(\.dismiss) private var dismiss

    @State private var tempOperator: TelecomOperator?
    @State private var tempStatus: TransactionStatus?
    @State private var tempDateFilter: TransactionDateFilter = .all
    @State private var tempStartDate: Date = Date()
    @State private var tempEndDate: Date = Date()
    @State private var isCustomDateSelected: Bool = false

    init(viewModel: VM) {
        self.viewModel = viewModel
        _tempOperator = State(initialValue: viewModel.selectedOperator)
        _tempStatus = State(initialValue: viewModel.selectedStatus)
        _tempDateFilter = State(initialValue: viewModel.selectedDateFilter)
        _tempStartDate = State(initialValue: viewModel.customStartDate)
        _tempEndDate = State(initialValue: viewModel.customEndDate)
        if case .custom = viewModel.selectedDateFilter {
            _isCustomDateSelected = State(initialValue: true)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LayoutMetrics.spacingLarge) {
                    // Operator Filter
                    VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                        Text(String(localized: "filter_operator"))
                            .font(.headline)
                            .foregroundStyle(.primary)

                        HStack(spacing: LayoutMetrics.spacingSmall) {
                            // "All" option
                            let isAllSelected = tempOperator == nil
                            Button(action: {
                                tempOperator = nil
                            }) {
                                Text(String(localized: "filter_all"))
                                    .font(.subheadline)
                                    .fontWeight(isAllSelected ? .semibold : .regular)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(isAllSelected ? Color.accentColor : AppColors.cardSurface)
                                    .foregroundStyle(isAllSelected ? Color.white : Color.primary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(isAllSelected ? Color.clear : AppColors.cardBorder, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)

                            // Dynamic available operators from viewModel
                            ForEach(viewModel.availableOperators, id: \.self) { op in
                                let isSelected = tempOperator == op
                                Button(action: {
                                    tempOperator = op
                                }) {
                                    Text(op.displayName)
                                        .font(.subheadline)
                                        .fontWeight(isSelected ? .semibold : .regular)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
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

                    // Status Filter
                    VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                        Text(String(localized: "filter_status"))
                            .font(.headline)
                            .foregroundStyle(.primary)

                        HStack(spacing: LayoutMetrics.spacingSmall) {
                            // "All" option
                            let isAllSelected = tempStatus == nil
                            Button(action: {
                                tempStatus = nil
                            }) {
                                Text(String(localized: "filter_all"))
                                    .font(.subheadline)
                                    .fontWeight(isAllSelected ? .semibold : .regular)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(isAllSelected ? Color.accentColor : AppColors.cardSurface)
                                    .foregroundStyle(isAllSelected ? Color.white : Color.primary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(isAllSelected ? Color.clear : AppColors.cardBorder, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)

                            ForEach(TransactionStatus.allCases, id: \.self) { status in
                                let isSelected = tempStatus == status
                                Button(action: {
                                    tempStatus = status
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: status.systemIconName)
                                            .font(.caption2)
                                        Text(status.localizedTitle)
                                            .font(.subheadline)
                                            .fontWeight(isSelected ? .semibold : .regular)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? status.statusColor : AppColors.cardSurface)
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

                    // Date Range Filter
                    VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                        Text(String(localized: "filter_date_range"))
                            .font(.headline)
                            .foregroundStyle(.primary)

                        let presets: [(TransactionDateFilter, String)] = [
                            (.all, String(localized: "filter_date_all")),
                            (.today, String(localized: "filter_date_today")),
                            (.last7Days, String(localized: "filter_date_7days")),
                            (.last30Days, String(localized: "filter_date_30days"))
                        ]

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LayoutMetrics.spacingSmall) {
                            ForEach(presets, id: \.1) { preset, title in
                                let isSelected = !isCustomDateSelected && tempDateFilter == preset
                                Button(action: {
                                    isCustomDateSelected = false
                                    tempDateFilter = preset
                                }) {
                                    Text(title)
                                        .font(.subheadline)
                                        .fontWeight(isSelected ? .semibold : .regular)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(isSelected ? Color.accentColor : AppColors.cardSurface)
                                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusSmall))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusSmall)
                                                .stroke(isSelected ? Color.clear : AppColors.cardBorder, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Custom Date Range Toggle
                        Button(action: {
                            isCustomDateSelected.toggle()
                            if isCustomDateSelected {
                                tempDateFilter = .custom(start: tempStartDate, end: tempEndDate)
                            } else {
                                tempDateFilter = .all
                            }
                        }) {
                            HStack {
                                Image(systemName: isCustomDateSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isCustomDateSelected ? Color.accentColor : Color.secondary)
                                Text(String(localized: "filter_date_custom"))
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .padding(.top, LayoutMetrics.spacingSmall)
                        }
                        .buttonStyle(.plain)

                        if isCustomDateSelected {
                            VStack(spacing: LayoutMetrics.spacingSmall) {
                                DatePicker(
                                    String(localized: "filter_start_date"),
                                    selection: $tempStartDate,
                                    displayedComponents: .date
                                )
                                .environment(\.calendar, Calendar(identifier: .gregorian))

                                DatePicker(
                                    String(localized: "filter_end_date"),
                                    selection: $tempEndDate,
                                    in: tempStartDate...,
                                    displayedComponents: .date
                                )
                                .environment(\.calendar, Calendar(identifier: .gregorian))
                            }
                            .padding(LayoutMetrics.spacingMedium)
                            .background(AppColors.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium))
                        }
                    }

                    // Action Buttons
                    HStack(spacing: LayoutMetrics.spacingMedium) {
                        Button(action: {
                            tempOperator = nil
                            tempStatus = nil
                            tempDateFilter = .all
                            isCustomDateSelected = false
                            viewModel.resetFilters()
                            dismiss()
                        }) {
                            Text(String(localized: "filter_reset"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: LayoutMetrics.primaryButtonHeight)
                                .background(AppColors.cardSurface)
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium))
                                .overlay(
                                    RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium)
                                        .stroke(AppColors.cardBorder, lineWidth: 1)
                                )
                        }

                        Button(action: {
                            viewModel.selectOperator(tempOperator)
                            viewModel.selectStatus(tempStatus)
                            if isCustomDateSelected {
                                viewModel.applyCustomDateRange(start: tempStartDate, end: tempEndDate)
                            } else {
                                viewModel.selectDateFilter(tempDateFilter)
                            }
                            dismiss()
                        }) {
                            Text(String(localized: "filter_apply"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: LayoutMetrics.primaryButtonHeight)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium))
                        }
                    }
                    .padding(.top, LayoutMetrics.spacingStandard)
                }
                .padding(LayoutMetrics.spacingStandard)
                .frame(maxWidth: LayoutMetrics.maxContentWidth)
                .frame(maxWidth: .infinity)
            }
            .background(AppColors.screenBackground)
            .navigationTitle(String(localized: "filter_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
