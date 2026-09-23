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
    var paths: [AppTab: NavigationPath] = [:]
    var presentedSheet: AppSheet? = nil
    var presentedCover: AppCover? = nil
    
    var path: NavigationPath {
        get { paths[.home, default: NavigationPath()] }
        set { paths[.home] = newValue }
    }
    
    var profilePath: NavigationPath {
        get { paths[.profile, default: NavigationPath()] }
        set { paths[.profile] = newValue }
    }
    
    // Spied invocations
    var navigatedRoutes: [AppRoute] = []
    var navigatedProfileRoutes: [AppRoute] = []
    var navigationInvocations: [(route: AppRoute, tab: AppTab?, autoSwitchTab: Bool)] = []
    var popCallCount: Int = 0
    var popInProfileCallCount: Int = 0
    var popCountInvocations: [(count: Int, tab: AppTab?)] = []
    var popToRootCallCount: Int = 0
    var popToRootInProfileCallCount: Int = 0
    var selectedTabs: [AppTab] = []
    var presentedSheets: [AppSheet] = []
    var presentedCovers: [AppCover] = []
    var dismissSheetCallCount: Int = 0
    var dismissCoverCallCount: Int = 0
    var dismissModalsCallCount: Int = 0
    var finishFlowInvocations: [(popCount: Int?, tab: AppTab?)] = []
    
    func path(for tab: AppTab) -> NavigationPath {
        paths[tab, default: NavigationPath()]
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
        
        var currentPath = paths[destinationTab, default: NavigationPath()]
        currentPath.append(route)
        paths[destinationTab] = currentPath
        
        if destinationTab == .profile {
            navigatedProfileRoutes.append(route)
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
    
    func pop(count: Int, in tab: AppTab? = nil) {
        popCallCount += 1
        popCountInvocations.append((count: count, tab: tab))
        
        let targetTab = tab ?? selectedTab
        var currentPath = paths[targetTab, default: NavigationPath()]
        guard !currentPath.isEmpty else { return }
        let popCount = min(count, currentPath.count)
        currentPath.removeLast(popCount)
        paths[targetTab] = currentPath
        
        if targetTab == .profile {
            popInProfileCallCount += 1
        }
    }
    
    func pop() {
        popCallCount += 1
        var currentPath = paths[.home, default: NavigationPath()]
        if !currentPath.isEmpty {
            currentPath.removeLast()
            paths[.home] = currentPath
        }
    }
    
    func popInProfile() {
        popInProfileCallCount += 1
        var currentPath = paths[.profile, default: NavigationPath()]
        if !currentPath.isEmpty {
            currentPath.removeLast()
            paths[.profile] = currentPath
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
        paths[.home] = NavigationPath()
    }
    
    func popToRootInProfile() {
        popToRootInProfileCallCount += 1
        paths[.profile] = NavigationPath()
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
    
    func dismissModals() {
        dismissModalsCallCount += 1
        presentedSheet = nil
        presentedCover = nil
    }
    
    func finishFlow(popCount: Int? = nil, in tab: AppTab? = nil) {
        finishFlowInvocations.append((popCount: popCount, tab: tab))
        dismissModals()
        if let popCount {
            pop(count: popCount, in: tab)
        } else {
            popToRoot(in: tab)
        }
    }
    
}
