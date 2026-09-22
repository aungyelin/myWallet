//
//  AppRouterProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

@MainActor
public protocol AppRouterProtocol: AnyObject {
    /// The active root navigation tab.
    var selectedTab: AppTab { get set }
    
    /// The active navigation path bound to the primary (Home) `NavigationStack`.
    var path: NavigationPath { get set }
    
    /// The navigation path bound to the Profile `NavigationStack`.
    var profilePath: NavigationPath { get set }
    
    /// The currently presented modal sheet, if any.
    var presentedSheet: AppSheet? { get set }
    
    /// The currently presented full-screen cover, if any.
    var presentedCover: AppCover? { get set }
    
    /// Retrieves the navigation path bound to the specified tab.
    /// - Parameter tab: The target `AppTab`.
    func path(for tab: AppTab) -> NavigationPath
    
    /// Switches the active root navigation tab.
    /// - Parameter tab: The target `AppTab`.
    func selectTab(_ tab: AppTab)
    
    /// Navigates forward to the specified destination route contextually.
    /// - Parameters:
    ///   - route: The target `AppRoute`.
    ///   - tab: Optional target `AppTab`. If `nil`, resolves to `route.defaultTab`.
    ///   - autoSwitchTab: Whether to activate the target tab if not already selected.
    func navigate(to route: AppRoute, on tab: AppTab?, autoSwitchTab: Bool)
    
    /// Navigates forward to the specified destination route within the appropriate tab.
    /// - Parameter route: The target `AppRoute`.
    func navigate(to route: AppRoute)
    
    /// Navigates forward to the specified destination route within the Profile tab stack.
    /// - Parameter route: The target `AppRoute`.
    func navigateInProfile(to route: AppRoute)
    
    /// Pops the top-most view off the navigation stack of the specified tab (or the active tab if omitted).
    /// - Parameter tab: The target tab, or `nil` to pop the currently selected tab.
    func pop(in tab: AppTab?)
    
    /// Pops the top-most view off the primary (Home) navigation stack.
    func pop()
    
    /// Pops the top-most view off the Profile navigation stack.
    func popInProfile()
    
    /// Clears the navigation stack and returns to root for the specified tab (or the active tab if omitted).
    /// - Parameter tab: The target tab, or `nil` to clear the currently selected tab.
    func popToRoot(in tab: AppTab?)
    
    /// Clears the primary (Home) navigation stack and returns to the root view.
    func popToRoot()
    
    /// Clears the Profile navigation stack and returns to the root view.
    func popToRootInProfile()
    
    /// Presents a modal sheet.
    /// - Parameter sheet: The target `AppSheet`.
    func present(sheet: AppSheet)
    
    /// Dismisses the currently presented modal sheet.
    func dismissSheet()
    
    /// Presents a full-screen cover.
    /// - Parameter cover: The target `AppCover`.
    func present(cover: AppCover)
    
    /// Dismisses the currently presented full-screen cover.
    func dismissCover()
}

// MARK: - Default Implementations
public extension AppRouterProtocol {
    func navigate(to route: AppRoute) {
        navigate(to: route, on: nil, autoSwitchTab: true)
    }
    
    func navigate(to route: AppRoute, on tab: AppTab?) {
        navigate(to: route, on: tab, autoSwitchTab: true)
    }
    
    func navigateInProfile(to route: AppRoute) {
        navigate(to: route, on: .profile, autoSwitchTab: true)
    }
    
    func pop() {
        pop(in: nil)
    }
    
    func popInProfile() {
        pop(in: .profile)
    }
    
    func popToRoot() {
        popToRoot(in: nil)
    }
    
    func popToRootInProfile() {
        popToRoot(in: .profile)
    }
}
