//
//  AppRouterTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Testing
import SwiftUI
@testable import myWallet

@Suite("AppRouter Tests")
@MainActor
struct AppRouterTests {
    
    @Test("AppRouter initializes with empty navigation paths and default tab")
    func initialRouterState() {
        let router = AppRouter()
        #expect(router.path.isEmpty)
        #expect(router.path.count == 0)
        #expect(router.profilePath.isEmpty)
        #expect(router.profilePath.count == 0)
        #expect(router.selectedTab == .home)
        #expect(router.presentedSheet == nil)
        #expect(router.presentedCover == nil)
    }
    
    @Test("selectTab(_:) switches active root tab")
    func tabSelection() {
        let router = AppRouter()
        #expect(router.selectedTab == .home)
        
        router.selectTab(.profile)
        #expect(router.selectedTab == .profile)
        
        router.selectTab(.home)
        #expect(router.selectedTab == .home)
    }
    
    @Test("navigate(to:) pushes routes onto the navigation path using DTOs")
    func navigatePushesRoutes() {
        let router = AppRouter()
        
        router.navigate(to: .topUp)
        #expect(!router.path.isEmpty)
        #expect(router.path.count == 1)
        
        let checkoutParams = TopUpCheckoutParams(
            phone: "09250000000",
            operatorType: .mpt,
            planTitle: "10,000 Ks Top-Up",
            amount: 10000
        )
        router.navigate(to: .topUpDetail(checkoutParams))
        #expect(router.path.count == 2)
    }
    
    @Test("pop() removes the top-most route from the navigation path")
    func popRemovesTopRoute() {
        let router = AppRouter()
        
        let checkoutParams = TopUpCheckoutParams(
            phone: "09250000000",
            operatorType: .mpt,
            planTitle: "10,000 Ks Top-Up",
            amount: 10000
        )
        router.navigate(to: .topUp)
        router.navigate(to: .topUpDetail(checkoutParams))
        #expect(router.path.count == 2)
        
        router.pop()
        #expect(router.path.count == 1)
        
        router.pop()
        #expect(router.path.count == 0)
        #expect(router.path.isEmpty)
    }
    
    @Test("pop() on an empty path does not crash or underflow")
    func popOnEmptyPathIsSafe() {
        let router = AppRouter()
        #expect(router.path.isEmpty)
        
        router.pop()
        #expect(router.path.isEmpty)
    }
    
    @Test("popToRoot() resets navigation path to zero regardless of depth")
    func popToRootResetsEntirePath() {
        let router = AppRouter()
        
        let checkoutParams = TopUpCheckoutParams(
            phone: "09250000000",
            operatorType: .mpt,
            planTitle: "10,000 Ks Top-Up",
            amount: 10000
        )
        let receiptParams = TopUpReceiptParams(
            referenceNumber: "TXN-20260922-839201",
            phone: "09250000000",
            operatorType: .mpt,
            planTitle: "10,000 Ks Top-Up",
            amount: 10000
        )
        
        router.navigate(to: .topUp)
        router.navigate(to: .topUpDetail(checkoutParams))
        router.navigate(to: .topUpSuccess(receiptParams))
        #expect(router.path.count == 3)
        
        router.popToRoot()
        #expect(router.path.count == 0)
        #expect(router.path.isEmpty)
    }
    
    @Test("Profile navigation routes correctly into profilePath")
    func profileNavigation() {
        let router = AppRouter()
        #expect(router.profilePath.isEmpty)
        
        router.navigate(to: .themeSettings)
        #expect(router.profilePath.count == 1)
        #expect(router.path.isEmpty) // Home path remains untouched
        
        router.popInProfile()
        #expect(router.profilePath.isEmpty)
        
        router.navigateInProfile(to: .themeSettings)
        #expect(router.profilePath.count == 1)
        
        router.popToRootInProfile()
        #expect(router.profilePath.isEmpty)
    }
    
    @Test("Modal sheet and cover presentation and dismissal")
    func modalCoordination() {
        let router = AppRouter()
        #expect(router.presentedSheet == nil)
        #expect(router.presentedCover == nil)
        
        router.present(sheet: .transactionFilter)
        #expect(router.presentedSheet == .transactionFilter)
        
        router.dismissSheet()
        #expect(router.presentedSheet == nil)
        
        let receiptParams = TopUpReceiptParams(
            referenceNumber: "TXN-001",
            phone: "09250000000",
            operatorType: .atom,
            planTitle: "5,000 Ks Top-Up",
            amount: 5000
        )
        router.present(cover: .topUpSuccess(receiptParams))
        #expect(router.presentedCover == .topUpSuccess(receiptParams))
        
        router.dismissCover()
        #expect(router.presentedCover == nil)
    }
    
    @Test("AppRoute enum conforms to Hashable and Equatable correctly with DTOs")
    func appRouteHashable() {
        let checkout1 = TopUpCheckoutParams(phone: "09250000000", operatorType: .mpt, planTitle: "10,000 Ks", amount: 10000)
        let checkout2 = TopUpCheckoutParams(phone: "09250000000", operatorType: .mpt, planTitle: "10,000 Ks", amount: 10000)
        let checkout3 = TopUpCheckoutParams(phone: "09770000000", operatorType: .atom, planTitle: "5,000 Ks", amount: 5000)
        
        let route1 = AppRoute.topUpDetail(checkout1)
        let route2 = AppRoute.topUpDetail(checkout2)
        let route3 = AppRoute.topUpDetail(checkout3)
        let route4 = AppRoute.topUp
        let route5 = AppRoute.themeSettings
        
        #expect(route1 == route2)
        #expect(route1 != route3)
        #expect(route1 != route4)
        #expect(route5 != route4)
        
        let set: Set<AppRoute> = [route1, route2, route3, route4, route5]
        #expect(set.count == 4) // route1/route2, route3, route4, route5
    }
    
    @Test("AppTab enum raw values and ids")
    func appTabProperties() {
        #expect(AppTab.home.rawValue == 0)
        #expect(AppTab.profile.rawValue == 1)
        #expect(AppTab.home.id == 0)
        #expect(AppTab.allCases.count == 2)
    }
    
    @Test("AppSheet and AppCover provide unique non-empty identifiers")
    func modalIdentifiers() {
        let filterSheet = AppSheet.transactionFilter
        let detailSheet = AppSheet.transactionDetail(referenceNumber: "TXN-999")
        #expect(!filterSheet.id.isEmpty)
        #expect(!detailSheet.id.isEmpty)
        #expect(filterSheet.id != detailSheet.id)
        
        let receiptParams = TopUpReceiptParams(
            referenceNumber: "TXN-COVER-01",
            phone: "09250000000",
            operatorType: .mpt,
            planTitle: "Test",
            amount: 1000
        )
        let cover = AppCover.topUpSuccess(receiptParams)
        #expect(!cover.id.isEmpty)
    }
    
    @Test("MockAppRouter spies on calls accurately")
    func mockAppRouterSpy() {
        let mock = MockAppRouter()
        
        mock.selectTab(.profile)
        #expect(mock.selectedTab == .profile)
        #expect(mock.selectedTabs == [.profile])
        
        mock.navigate(to: .topUp)
        #expect(mock.navigatedRoutes == [.topUp])
        
        mock.navigateInProfile(to: .themeSettings)
        #expect(mock.navigatedProfileRoutes == [.themeSettings])
        
        mock.present(sheet: .transactionFilter)
        #expect(mock.presentedSheet == .transactionFilter)
        #expect(mock.presentedSheets == [.transactionFilter])
        
        mock.dismissSheet()
        #expect(mock.dismissSheetCallCount == 1)
        #expect(mock.presentedSheet == nil)
        
        mock.pop()
        #expect(mock.popCallCount == 1)
        
        mock.popToRoot()
        #expect(mock.popToRootCallCount == 1)
    }
    
    @Test("AppTheme maps to expected ColorScheme, localized display names, and icons")
    func appThemeProperties() {
        #expect(AppTheme.system.colorScheme == nil)
        #expect(AppTheme.light.colorScheme == .light)
        #expect(AppTheme.dark.colorScheme == .dark)
        
        for theme in AppTheme.allCases {
            #expect(!theme.displayName.isEmpty)
            #expect(!theme.iconName.isEmpty)
            #expect(!theme.id.isEmpty)
        }
    }
    
    @Test("AppRoute maps to expected defaultTab")
    func appRouteDefaultTabMapping() {
        let checkoutParams = TopUpCheckoutParams(
            phone: "09250000000",
            operatorType: .mpt,
            planTitle: "10,000 Ks Top-Up",
            amount: 10000
        )
        let receiptParams = TopUpReceiptParams(
            referenceNumber: "TXN-001",
            phone: "09250000000",
            operatorType: .mpt,
            planTitle: "10,000 Ks Top-Up",
            amount: 10000
        )
        
        #expect(AppRoute.topUp.defaultTab == .home)
        #expect(AppRoute.topUpDetail(checkoutParams).defaultTab == .home)
        #expect(AppRoute.topUpSuccess(receiptParams).defaultTab == .home)
        #expect(AppRoute.transactionHistory.defaultTab == .home)
        #expect(AppRoute.transactionDetail(referenceNumber: "TXN-001").defaultTab == .home)
        #expect(AppRoute.themeSettings.defaultTab == .profile)
    }
    
    @Test("navigate(to:) contextually switches selectedTab when navigating cross-tab")
    func contextualCrossTabNavigation() {
        let router = AppRouter()
        #expect(router.selectedTab == .home)
        #expect(router.profilePath.isEmpty)
        
        // Navigating to .themeSettings from home should switch selectedTab to .profile
        router.navigate(to: .themeSettings)
        #expect(router.selectedTab == .profile)
        #expect(router.profilePath.count == 1)
        #expect(router.path.isEmpty)
        
        // Navigating to .topUp from profile should switch selectedTab to .home
        router.navigate(to: .topUp)
        #expect(router.selectedTab == .home)
        #expect(router.path.count == 1)
        #expect(router.profilePath.count == 1)
    }
    
    @Test("navigate(to:on:autoSwitchTab:) respects autoSwitchTab false")
    func navigationWithoutAutoSwitchTab() {
        let router = AppRouter()
        #expect(router.selectedTab == .home)
        
        router.navigate(to: .themeSettings, on: nil, autoSwitchTab: false)
        #expect(router.selectedTab == .home)
        #expect(router.profilePath.count == 1)
        #expect(router.path.isEmpty)
    }
    
    @Test("navigate(to:on:) pushes onto specified target tab override")
    func explicitTabOverride() {
        let router = AppRouter()
        #expect(router.selectedTab == .home)
        
        // Push .themeSettings onto .home stack explicitly
        router.navigate(to: .themeSettings, on: .home)
        #expect(router.path.count == 1)
        #expect(router.profilePath.isEmpty)
        #expect(router.selectedTab == .home)
    }
    
    @Test("Contextual pop() and popToRoot() act on currently selectedTab")
    func contextualPopAndPopToRoot() {
        let router = AppRouter()
        
        router.navigate(to: .topUp)
        #expect(router.path.count == 1)
        
        router.navigate(to: .themeSettings)
        #expect(router.selectedTab == .profile)
        #expect(router.profilePath.count == 1)
        
        // Calling contextual pop() while on .profile should pop profilePath
        router.pop()
        #expect(router.profilePath.isEmpty)
        #expect(router.path.count == 1)
        
        // Switch to .home, push another route, popToRoot()
        router.selectTab(.home)
        router.navigate(to: .transactionHistory)
        #expect(router.path.count == 2)
        
        router.popToRoot()
        #expect(router.path.isEmpty)
    }
    
    @Test("path(for:) returns correct NavigationPath for each tab")
    func pathForTab() {
        let router = AppRouter()
        
        #expect(router.path(for: .home).isEmpty)
        #expect(router.path(for: .profile).isEmpty)
        
        router.navigate(to: .topUp)
        #expect(router.path(for: .home).count == 1)
        #expect(router.path(for: .profile).isEmpty)
    }
    
    @Test("AppContainer composition root exposes and shares appRouter")
    func appContainerCompositionRoot() throws {
        let customRouter = AppRouter()
        let container = try AppContainer.createInMemory(router: customRouter)
        
        #expect(container.appRouter === customRouter)
        
        // Verify navigation through container
        container.appRouter.navigate(to: .topUp)
        #expect(container.appRouter.path.count == 1)
    }
}
