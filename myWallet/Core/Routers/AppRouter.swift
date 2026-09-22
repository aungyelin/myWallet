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
    public var path: NavigationPath
    public var profilePath: NavigationPath
    public var presentedSheet: AppSheet?
    public var presentedCover: AppCover?
    
    public init(
        selectedTab: AppTab = .home,
        path: NavigationPath = NavigationPath(),
        profilePath: NavigationPath = NavigationPath(),
        presentedSheet: AppSheet? = nil,
        presentedCover: AppCover? = nil
    ) {
        self.selectedTab = selectedTab
        self.path = path
        self.profilePath = profilePath
        self.presentedSheet = presentedSheet
        self.presentedCover = presentedCover
    }
    
    public func path(for tab: AppTab) -> NavigationPath {
        switch tab {
        case .home:
            return path
        case .profile:
            return profilePath
        }
    }
    
    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }
    
    public func navigate(to route: AppRoute, on tab: AppTab? = nil, autoSwitchTab: Bool = true) {
        let destinationTab = tab ?? route.defaultTab
        
        if autoSwitchTab && selectedTab != destinationTab {
            selectedTab = destinationTab
        }
        
        switch destinationTab {
        case .home:
            path.append(route)
        case .profile:
            profilePath.append(route)
        }
    }
    
    public func navigate(to route: AppRoute) {
        navigate(to: route, on: nil, autoSwitchTab: true)
    }
    
    public func navigateInProfile(to route: AppRoute) {
        navigate(to: route, on: .profile, autoSwitchTab: true)
    }
    
    public func pop(in tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        switch targetTab {
        case .home:
            guard !path.isEmpty else { return }
            path.removeLast()
        case .profile:
            guard !profilePath.isEmpty else { return }
            profilePath.removeLast()
        }
    }
    
    public func pop() {
        pop(in: nil)
    }
    
    public func popInProfile() {
        pop(in: .profile)
    }
    
    public func popToRoot(in tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        switch targetTab {
        case .home:
            guard !path.isEmpty else { return }
            path.removeLast(path.count)
        case .profile:
            guard !profilePath.isEmpty else { return }
            profilePath.removeLast(profilePath.count)
        }
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
    
}

// MARK: - SwiftUI Environment Integration
private struct AppRouterKey: EnvironmentKey {
    static let defaultValue: (any AppRouterProtocol)? = nil
}

extension EnvironmentValues {
    public var appRouter: (any AppRouterProtocol)? {
        get { self[AppRouterKey.self] }
        set { self[AppRouterKey.self] = newValue }
    }
}
