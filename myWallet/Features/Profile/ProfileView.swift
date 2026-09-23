//
//  ProfileView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.themeManager) private var themeManager
    @Environment(\.languageManager) private var languageManager
    
    var body: some View {
        let currentLang = languageManager.currentLanguage
        ScrollView {
            VStack(spacing: LayoutMetrics.spacingLarge) {
                // Custom Screen Header (matching Home screen header)
                ScreenHeaderView(title: AppLocalization.string("profile_screen_title", language: currentLang))
                
                // Profile Card (same size, elevation, and padding as BalanceCardView)
                ProfileCardView(
                    title: AppLocalization.string("nav_profile", language: currentLang),
                    subtitle: AppLocalization.string("app_name", language: currentLang)
                )
                
                // Preferences Section
                VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                    Text(AppLocalization.string("profile_section_preferences", language: currentLang))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, LayoutMetrics.headerHorizontalPadding)
                    VStack(spacing: 0) {
                        preferenceRow(
                            leadingView: {
                                Image(systemName: themeManager.currentTheme.iconName)
                                    .font(.system(size: LayoutMetrics.iconSizeMedium))
                                    .foregroundStyle(Color.accentColor)
                                    .frame(width: LayoutMetrics.iconSizeLarge, height: LayoutMetrics.iconSizeLarge)
                            },
                            title: AppLocalization.string("profile_theme_setting", language: currentLang),
                            detail: themeManager.currentTheme.displayName,
                            accessibilityLabel: "\(AppLocalization.string("profile_theme_setting", language: currentLang)), \(themeManager.currentTheme.displayName)",
                            accessibilityHint: AppLocalization.string("profile_theme_description", language: currentLang)
                        ) {
                            appContainer?.appRouter.navigate(to: .themeSettings)
                        }

                        Divider()
                            .padding(.leading, LayoutMetrics.balanceCardPadding + LayoutMetrics.iconSizeLarge + LayoutMetrics.spacingMedium)

                        preferenceRow(
                            leadingView: {
                                localeBadge(for: currentLang)
                            },
                            title: AppLocalization.string("profile_language_setting", language: currentLang),
                            detail: currentLang.displayName(in: currentLang),
                            accessibilityLabel: AppLocalization.string("profile_language_setting", language: currentLang)
                        ) {
                            appContainer?.appRouter.navigate(to: .languageSettings)
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius, style: .continuous)
                            .fill(AppColors.cardSurface)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                            .overlay {
                                RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius, style: .continuous)
                                    .strokeBorder(AppColors.cardBorder, lineWidth: 1)
                            }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.balanceCardCornerRadius, style: .continuous))
                    .padding(.horizontal, LayoutMetrics.screenHorizontalPadding)
                }
                .frame(maxWidth: LayoutMetrics.maxContentWidth)
                
                Spacer(minLength: LayoutMetrics.spacingExtraLarge)
            }
            .frame(maxWidth: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(AppColors.screenBackground)
    }

    @ViewBuilder
    private func localeBadge(for language: AppLanguage) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusSmall, style: .continuous)
                .fill(Color.accentColor.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusSmall, style: .continuous)
                        .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
                )

            Text(language.scriptSymbol)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.accentColor)
        }
        .frame(width: LayoutMetrics.iconSizeLarge, height: LayoutMetrics.iconSizeLarge)
    }

    private func preferenceRow<LeadingContent: View>(
        @ViewBuilder leadingView: () -> LeadingContent,
        title: String,
        detail: String,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: LayoutMetrics.spacingMedium) {
                leadingView()

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(LayoutMetrics.balanceCardPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(.isButton)
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
