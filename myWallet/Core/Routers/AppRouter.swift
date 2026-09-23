//
//  AppRouter.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI
import Observation

@Observable
@MainActor
public final class AppRouter: AppRouterProtocol {
    
    public var selectedTab: AppTab
    public var paths: [AppTab: NavigationPath]
    public var presentedSheet: AppSheet?
    public var presentedCover: AppCover?
    
    public var path: NavigationPath {
        get { paths[.home, default: NavigationPath()] }
        set { paths[.home] = newValue }
    }
    
    public var profilePath: NavigationPath {
        get { paths[.profile, default: NavigationPath()] }
        set { paths[.profile] = newValue }
    }
    
    public init(
        selectedTab: AppTab = .home,
        path: NavigationPath = NavigationPath(),
        profilePath: NavigationPath = NavigationPath(),
        paths: [AppTab: NavigationPath]? = nil,
        presentedSheet: AppSheet? = nil,
        presentedCover: AppCover? = nil
    ) {
        self.selectedTab = selectedTab
        var initialPaths = paths ?? [:]
        if initialPaths[.home] == nil {
            initialPaths[.home] = path
        }
        if initialPaths[.profile] == nil {
            initialPaths[.profile] = profilePath
        }
        self.paths = initialPaths
        self.presentedSheet = presentedSheet
        self.presentedCover = presentedCover
    }
    
    public func path(for tab: AppTab) -> NavigationPath {
        paths[tab, default: NavigationPath()]
    }
    
    public func setPath(_ path: NavigationPath, for tab: AppTab) {
        paths[tab] = path
    }
    
    public func binding(for tab: AppTab) -> Binding<NavigationPath> {
        Binding(
            get: { self.path(for: tab) },
            set: { self.setPath($0, for: tab) }
        )
    }
    
    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }
    
    public func navigate(to route: AppRoute, on tab: AppTab? = nil, autoSwitchTab: Bool = true) {
        let destinationTab = tab ?? route.defaultTab
        
        if autoSwitchTab && selectedTab != destinationTab {
            selectedTab = destinationTab
        }
        
        var currentPath = paths[destinationTab, default: NavigationPath()]
        currentPath.append(route)
        paths[destinationTab] = currentPath
    }
    
    public func navigate(to route: AppRoute) {
        navigate(to: route, on: nil, autoSwitchTab: true)
    }
    
    public func navigateInProfile(to route: AppRoute) {
        navigate(to: route, on: .profile, autoSwitchTab: true)
    }
    
    public func pop(in tab: AppTab? = nil) {
        pop(count: 1, in: tab)
    }
    
    public func pop(count: Int, in tab: AppTab? = nil) {
        guard count > 0 else { return }
        let targetTab = tab ?? selectedTab
        var currentPath = paths[targetTab, default: NavigationPath()]
        guard !currentPath.isEmpty else { return }
        
        let popCount = min(count, currentPath.count)
        currentPath.removeLast(popCount)
        paths[targetTab] = currentPath
    }
    
    public func pop() {
        pop(count: 1, in: nil)
    }
    
    public func popInProfile() {
        pop(count: 1, in: .profile)
    }
    
    public func popToRoot(in tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        paths[targetTab] = NavigationPath()
    }
    
    public func popToRoot() {
        popToRoot(in: nil)
    }
    
    public func popToRootInProfile() {
        popToRoot(in: .profile)
    }
    
    public func present(sheet: AppSheet) {
        presentedSheet = sheet
    }
    
    public func dismissSheet() {
        presentedSheet = nil
    }
    
    public func present(cover: AppCover) {
        presentedCover = cover
    }
    
    public func dismissCover() {
        presentedCover = nil
    }
    
    public func dismissModals() {
        presentedSheet = nil
        presentedCover = nil
    }
    
    public func finishFlow(popCount: Int? = nil, in tab: AppTab? = nil) {
        dismissModals()
        if let popCount {
            pop(count: popCount, in: tab)
        } else {
            popToRoot(in: tab)
        }
    }
    
}
