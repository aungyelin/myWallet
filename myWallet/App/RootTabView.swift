//
//  RootTabView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

@MainActor
struct RootTabView: View {
    @Bindable var router: AppRouter
    @Environment(\.themeManager) private var themeManager
    @Environment(\.languageManager) private var languageManager
    
    @MainActor
    init(router: AppRouter) {
        self.router = router
    }
    
    @MainActor
    init() {
        self.router = AppRouter()
    }
    
    var body: some View {
        TabView(selection: tabBinding) {
            NavigationStack(path: $router.path) {
                HomeView()
                    .withAppNavigationDestinations()
            }
            .tabItem {
                Label(AppLocalization.string("nav_home"), systemImage: "house.fill")
            }
            .tag(AppTab.home)
            
            NavigationStack(path: $router.profilePath) {
                ProfileView()
                    .withAppNavigationDestinations()
            }
            .tabItem {
                Label(AppLocalization.string("nav_profile"), systemImage: "person.fill")
            }
            .tag(AppTab.profile)
        }
        .sheet(item: $router.presentedSheet) { sheet in
            AppRouteDestinationFactory.sheet(for: sheet)
        }
        .fullScreenCover(item: $router.presentedCover) { cover in
            AppRouteDestinationFactory.cover(for: cover)
        }
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .environment(\.locale, languageManager.currentLanguage.locale)
    }
    
    /// Tab binding with iOS platform convention: re-tapping the active tab pops its navigation stack to root.
    private var tabBinding: Binding<AppTab> {
        Binding(
            get: { router.selectedTab },
            set: { newTab in
                if newTab == router.selectedTab {
                    router.popToRoot(in: newTab)
                } else {
                    router.selectedTab = newTab
                }
            }
        )
    }
}

#Preview("RootTabView - iPhone") {
    RootTabView()
}
