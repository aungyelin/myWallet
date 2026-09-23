//
//  AppRouteDestinationFactory.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

/// Centralized view factory resolving abstract routes, sheets, and full-screen covers into concrete SwiftUI views.
@MainActor
public enum AppRouteDestinationFactory {
    
    @ViewBuilder
    public static func view(for route: AppRoute) -> some View {
        switch route {
        case .topUp:
            TopUpMainView()
        case .topUpDetail(let params):
            TopUpDetailView(params: params)
        case .topUpSuccess(let params):
            TopUpSuccessView(params: params)
        case .transactionHistory:
            TransactionHistoryView()
        case .transactionDetail(let referenceNumber):
            TransactionDetailView(referenceNumber: referenceNumber)
        case .themeSettings:
            ThemeSettingsView()
        case .languageSettings:
            LanguageSettingsView()
        }
    }
    
    @ViewBuilder
    public static func sheet(for sheet: AppSheet) -> some View {
        switch sheet {
        case .transactionFilter:
            TransactionHistoryView()
        case .transactionDetail(let referenceNumber):
            TransactionDetailView(referenceNumber: referenceNumber)
        }
    }
    
    @ViewBuilder
    public static func cover(for cover: AppCover) -> some View {
        switch cover {
        case .topUpSuccess(let params):
            TopUpSuccessView(params: params)
        }
    }
    
}

// MARK: - View Extension Helpers
extension View {
    public func withAppNavigationDestinations() -> some View {
        self.navigationDestination(for: AppRoute.self) { route in
            AppRouteDestinationFactory.view(for: route)
        }
    }
}
