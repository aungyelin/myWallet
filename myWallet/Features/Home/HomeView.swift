//
//  HomeView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

@MainActor
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @Environment(\.appRouter) private var router
    
    init(viewModel: HomeViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    init() {
        _viewModel = State(wrappedValue: HomeViewModel())
    }
    
    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: LayoutMetrics.spacingStandard),
            count: LayoutMetrics.actionGridColumnsCount
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: LayoutMetrics.spacingLarge) {
                // Custom Screen Header (replacing built-in navigation title)
                ScreenHeaderView(title: String(localized: "home_screen_title"))
                
                // Account Balance Card with visibility toggle (* * * * * * mask)
                BalanceCardView(
                    title: String(localized: "home_balance_title"),
                    formattedBalance: viewModel.formattedBalance,
                    isHidden: viewModel.isBalanceHidden,
                    onToggleVisibility: {
                        viewModel.toggleBalanceVisibility()
                    }
                )
                
                // Quick-Action Mini Circular Buttons Grid
                VStack(alignment: .leading, spacing: LayoutMetrics.spacingMedium) {
                    LazyVGrid(columns: gridColumns, spacing: LayoutMetrics.spacingLarge) {
                        QuickActionButton(
                            title: String(localized: "btn_top_up"),
                            iconName: "iphone.gen3",
                            action: {
                                viewModel.navigateToTopUp(router: router)
                            }
                        )
                        
                        QuickActionButton(
                            title: String(localized: "btn_history"),
                            iconName: "clock.arrow.circlepath",
                            action: {
                                viewModel.navigateToHistory(router: router)
                            }
                        )
                    }
                    .padding(.horizontal, LayoutMetrics.screenHorizontalPadding)
                }
                .frame(maxWidth: LayoutMetrics.maxContentWidth)
                
                Spacer(minLength: LayoutMetrics.spacingExtraLarge)
            }
            .frame(maxWidth: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(AppColors.screenBackground)
    }
}

#Preview("HomeView - iPhone") {
    NavigationStack {
        HomeView()
    }
}

#Preview("HomeView - iPad", traits: .fixedLayout(width: 820, height: 1180)) {
    NavigationStack {
        HomeView()
    }
}
