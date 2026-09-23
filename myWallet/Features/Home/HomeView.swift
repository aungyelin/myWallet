//
//  HomeView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

@MainActor
struct HomeView<VM: HomeViewModelProtocol>: View {
    @Environment(\.appContainer) private var appContainer
    private let customViewModel: VM?
    
    init(viewModel: VM) {
        self.customViewModel = viewModel
    }

    var body: some View {
        if let customViewModel {
            HomeContentView(viewModel: customViewModel)
        } else if let appContainer {
            HomeContainerLoadedView(container: appContainer)
        } else {
            ProgressView()
        }
    }
}

extension HomeView where VM == HomeViewModel {
    init() {
        self.customViewModel = nil
    }
}

@MainActor
private struct HomeContainerLoadedView: View {
    @State private var viewModel: HomeViewModel

    init(container: any AppContainerProtocol) {
        _viewModel = State(wrappedValue: container.makeHomeViewModel())
    }

    var body: some View {
        HomeContentView(viewModel: viewModel)
    }
}

@MainActor
private struct HomeContentView<VM: HomeViewModelProtocol>: View {
    @Bindable var viewModel: VM

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
                ScreenHeaderView(title: AppLocalization.string("home_screen_title"))
                
                // Account Balance Card with visibility toggle (* * * * * * mask)
                BalanceCardView(
                    title: AppLocalization.string("home_balance_title"),
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
                            title: AppLocalization.string("btn_top_up"),
                            iconName: "iphone.gen3",
                            action: {
                                viewModel.navigateToTopUp()
                            }
                        )
                        
                        QuickActionButton(
                            title: AppLocalization.string("btn_history"),
                            iconName: "clock.arrow.circlepath",
                            action: {
                                viewModel.navigateToHistory()
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
