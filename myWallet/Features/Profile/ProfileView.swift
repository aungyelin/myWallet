//
//  ProfileView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.appRouter) private var router
    @Environment(\.themeManager) private var themeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: LayoutMetrics.spacingLarge) {
                // Custom Screen Header (matching Home screen header)
                ScreenHeaderView(title: String(localized: "profile_screen_title"))
                
                // Profile Card (same size, elevation, and padding as BalanceCardView)
                ProfileCardView(
                    title: String(localized: "nav_profile"),
                    subtitle: String(localized: "app_name")
                )
                
                // Preferences Section
                VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                    Text(String(localized: "profile_section_preferences"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, LayoutMetrics.headerHorizontalPadding)
                    
                    Button(action: {
                        router?.navigate(to: .themeSettings)
                    }) {
                        HStack(spacing: LayoutMetrics.spacingMedium) {
                            Image(systemName: themeManager.currentTheme.iconName)
                                .font(.system(size: LayoutMetrics.iconSizeMedium))
                                .foregroundStyle(Color.accentColor)
                                .frame(width: LayoutMetrics.iconSizeLarge)
                            
                            Text(String(localized: "profile_theme_setting"))
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text(themeManager.currentTheme.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(LayoutMetrics.balanceCardPadding)
                        .background {
                            RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius, style: .continuous)
                                .fill(AppColors.cardSurface)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                                .overlay {
                                    RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius, style: .continuous)
                                        .strokeBorder(AppColors.cardBorder, lineWidth: 1)
                                }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, LayoutMetrics.screenHorizontalPadding)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(String(localized: "profile_theme_setting")), \(themeManager.currentTheme.displayName)")
                    .accessibilityHint(String(localized: "profile_theme_description"))
                    .accessibilityAddTraits(.isButton)
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

#Preview("ProfileView - iPhone") {
    NavigationStack {
        ProfileView()
    }
    .environment(\.themeManager, ThemeManager())
}

#Preview("ProfileView - iPad", traits: .fixedLayout(width: 820, height: 1180)) {
    NavigationStack {
        ProfileView()
    }
    .environment(\.themeManager, ThemeManager())
}
