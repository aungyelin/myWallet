//
//  ThemeSettingsView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

struct ThemeSettingsView: View {
    @Environment(\.themeManager) private var themeManager
    
    var body: some View {
        List {
            Section {
                ForEach(AppTheme.allCases) { theme in
                    Button(action: {
                        guard themeManager.currentTheme != theme else { return }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        themeManager.setTheme(theme)
                    }) {
                        HStack(spacing: LayoutMetrics.spacingMedium) {
                            Image(systemName: theme.iconName)
                                .font(.system(size: LayoutMetrics.iconSizeMedium))
                                .foregroundStyle(theme == themeManager.currentTheme ? Color.accentColor : .secondary)
                                .frame(width: LayoutMetrics.iconSizeLarge)
                            
                            Text(theme.displayName)
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if theme == themeManager.currentTheme {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(theme.displayName)
                    .accessibilityAddTraits(theme == themeManager.currentTheme ? [.isButton, .isSelected] : .isButton)
                }
            } footer: {
                Text(AppLocalization.string("profile_theme_description"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, LayoutMetrics.spacingMicro)
            }
        }
        .navigationTitle(AppLocalization.string("profile_theme_setting"))
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(AppColors.screenBackground)
    }
}

#Preview("ThemeSettingsView") {
    NavigationStack {
        ThemeSettingsView()
    }
}
