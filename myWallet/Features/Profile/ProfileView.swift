//
//  ProfileView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

/// Profile screen displaying user information and application settings.
struct ProfileView: View {
    @Environment(\.appRouter) private var router
    @Environment(\.themeManager) private var themeManager
    
    var body: some View {
        List {
            Section {
                HStack(spacing: LayoutMetrics.spacingMedium) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: LayoutMetrics.avatarSize))
                        .foregroundStyle(Color.accentColor)
                    
                    VStack(alignment: .leading, spacing: LayoutMetrics.spacingMicro) {
                        Text(String(localized: "nav_profile"))
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text(String(localized: "app_name"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, LayoutMetrics.spacingSmall)
            }
            
            Section(header: Text(String(localized: "profile_section_preferences"))) {
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
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(String(localized: "profile_theme_setting")), \(themeManager.currentTheme.displayName)")
                .accessibilityHint(String(localized: "profile_theme_description"))
                .accessibilityAddTraits(.isButton)
            }
        }
        .navigationTitle(String(localized: "nav_profile"))
    }
}

#Preview("ProfileView - iPhone") {
    NavigationStack {
        ProfileView()
    }
}
