//
//  TopUpDetailView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

struct TopUpDetailView: View {
    let params: TopUpCheckoutParams
    @Environment(\.appContainer) private var appContainer
    private let customViewModel: (any TopUpDetailViewModelProtocol)?

    public init(params: TopUpCheckoutParams, viewModel: (any TopUpDetailViewModelProtocol)? = nil) {
        self.params = params
        self.customViewModel = viewModel
    }

    var body: some View {
        if let customViewModel {
            TopUpDetailContentView(viewModel: customViewModel)
        } else if let appContainer {
            TopUpDetailContainerLoadedView(params: params, container: appContainer)
        } else {
            ProgressView()
        }
    }
}

private struct TopUpDetailContainerLoadedView: View {
    @State private var viewModel: TopUpDetailViewModel

    init(params: TopUpCheckoutParams, container: any AppContainerProtocol) {
        _viewModel = State(wrappedValue: TopUpDetailViewModel(
            params: params,
            topUpRepository: container.topUpRepository
        ))
    }

    var body: some View {
        TopUpDetailContentView(viewModel: viewModel)
    }
}

private struct TopUpDetailContentView: View {
    let viewModel: any TopUpDetailViewModelProtocol
    @Environment(\.appRouter) private var router
    @State private var showErrorAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: LayoutMetrics.spacingLarge) {
                
                // Operator Brand Card
                VStack(spacing: LayoutMetrics.spacingSmall) {
                    TelecomBadgeView(
                        operatorType: viewModel.params.operatorType,
                        style: .cardBadge
                    )

                    Text(viewModel.params.planTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(CurrencyFormatter.format(viewModel.params.amount))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.tint)
                }
                .padding(.vertical, LayoutMetrics.spacingMedium)

                // Order Summary Card
                VStack(spacing: LayoutMetrics.spacingMedium) {
                    Text(String(localized: "top_up_detail_summary_title"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    summaryRow(
                        title: String(localized: "top_up_detail_recipient"),
                        value: viewModel.params.phone
                    )

                    HStack(alignment: .center) {
                        Text(String(localized: "top_up_detail_operator"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack(spacing: LayoutMetrics.spacingSmall) {
                            TelecomLogoView(operatorType: viewModel.params.operatorType, size: 20)
                            Text(viewModel.params.operatorType.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }

                    summaryRow(
                        title: String(localized: "top_up_detail_plan"),
                        value: viewModel.params.planTitle
                    )

                    summaryRow(
                        title: String(localized: "top_up_fee"),
                        value: String(localized: "top_up_free_fee")
                    )

                    Divider()

                    HStack {
                        Text(String(localized: "top_up_detail_total"))
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Text(CurrencyFormatter.format(viewModel.params.amount + viewModel.params.fee))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.tint)
                    }
                }
                .padding(LayoutMetrics.spacingLarge)
                .background(AppColors.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )

                Spacer(minLength: LayoutMetrics.spacingMedium)

                // Primary Payment Confirmation Button
                Button(action: {
                    Task {
                        await viewModel.confirmPayment(router: router)
                        if viewModel.errorMessage != nil {
                            showErrorAlert = true
                        }
                    }
                }) {
                    HStack(spacing: LayoutMetrics.spacingSmall) {
                        if viewModel.isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "creditcard")
                            Text(String(localized: "btn_simulate_checkout"))
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: LayoutMetrics.primaryButtonHeight)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isProcessing)
                .padding(.horizontal, LayoutMetrics.spacingSmall)
            }
            .padding(.horizontal, LayoutMetrics.screenHorizontalPadding)
            .padding(.vertical, LayoutMetrics.spacingStandard)
            .frame(maxWidth: LayoutMetrics.maxContentWidth)
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.screenBackground)
        .navigationTitle(String(localized: "top_up_detail_title"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            String(localized: "top_up_detail_title"),
            isPresented: $showErrorAlert,
            actions: {
                Button(String(localized: "action_done")) {
                    showErrorAlert = false
                }
            },
            message: {
                Text(viewModel.errorMessage ?? "")
            }
        )
    }

    @ViewBuilder
    private func summaryRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview("TopUpDetailView") {
    NavigationStack {
        TopUpDetailView(
            params: TopUpCheckoutParams(
                phone: "09253366392",
                operatorType: .mpt,
                planTitle: "Combo 1000MB (YouTube; TikTok; Telegram) (7 Days)",
                amount: 998
            )
        )
    }
}
