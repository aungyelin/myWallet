//
//  MockAppRouter.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI
@testable import myWallet

/// Test spy implementing `AppRouterProtocol` for deterministic ViewModel unit tests.
@MainActor
final class MockAppRouter: AppRouterProtocol {
    
    var selectedTab: AppTab = .home
    var path: NavigationPath = NavigationPath()
    var profilePath: NavigationPath = NavigationPath()
    var presentedSheet: AppSheet? = nil
    var presentedCover: AppCover? = nil
    
    // Spied invocations
    var navigatedRoutes: [AppRoute] = []
    var navigatedProfileRoutes: [AppRoute] = []
    var navigationInvocations: [(route: AppRoute, tab: AppTab?, autoSwitchTab: Bool)] = []
    var popCallCount: Int = 0
    var popInProfileCallCount: Int = 0
    var popToRootCallCount: Int = 0
    var popToRootInProfileCallCount: Int = 0
    var selectedTabs: [AppTab] = []
    var presentedSheets: [AppSheet] = []
    var presentedCovers: [AppCover] = []
    var dismissSheetCallCount: Int = 0
    var dismissCoverCallCount: Int = 0
    
    func path(for tab: AppTab) -> NavigationPath {
        switch tab {
        case .home:
            return path
        case .profile:
            return profilePath
        }
    }
    
    func selectTab(_ tab: AppTab) {
        selectedTab = tab
        selectedTabs.append(tab)
    }
    
    func navigate(to route: AppRoute, on tab: AppTab? = nil, autoSwitchTab: Bool = true) {
        navigatedRoutes.append(route)
        navigationInvocations.append((route: route, tab: tab, autoSwitchTab: autoSwitchTab))
        
        let destinationTab = tab ?? route.defaultTab
        if autoSwitchTab {
            selectedTab = destinationTab
        }
        
        switch destinationTab {
        case .home:
            path.append(route)
        case .profile:
            navigatedProfileRoutes.append(route)
            profilePath.append(route)
        }
    }
    
    func navigate(to route: AppRoute) {
        navigate(to: route, on: nil, autoSwitchTab: true)
    }
    
    func navigateInProfile(to route: AppRoute) {
        navigate(to: route, on: .profile, autoSwitchTab: true)
    }
    
    func pop(in tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        switch targetTab {
        case .home:
            pop()
        case .profile:
            popInProfile()
        }
    }
    
    func pop() {
        popCallCount += 1
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popInProfile() {
        popInProfileCallCount += 1
        if !profilePath.isEmpty {
            profilePath.removeLast()
        }
    }
    
    func popToRoot(in tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        switch targetTab {
        case .home:
            popToRoot()
        case .profile:
            popToRootInProfile()
        }
    }
    
    func popToRoot() {
        popToRootCallCount += 1
        if !path.isEmpty {
            path.removeLast(path.count)
        }
    }
    
    func popToRootInProfile() {
        popToRootInProfileCallCount += 1
        if !profilePath.isEmpty {
            profilePath.removeLast(profilePath.count)
        }
    }
    
    func present(sheet: AppSheet) {
        presentedSheet = sheet
        presentedSheets.append(sheet)
    }
    
    func dismissSheet() {
        dismissSheetCallCount += 1
        presentedSheet = nil
    }
    
    func present(cover: AppCover) {
        presentedCover = cover
        presentedCovers.append(cover)
    }
    
    func dismissCover() {
        dismissCoverCallCount += 1
        presentedCover = nil
    }
}
