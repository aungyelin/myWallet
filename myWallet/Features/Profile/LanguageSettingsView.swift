//
//  LanguageSettingsView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import SwiftUI

struct LanguageSettingsView: View {
    @Environment(\.languageManager) private var languageManager

    var body: some View {
        let currentLang = languageManager.currentLanguage
        List {
            Section {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        guard languageManager.currentLanguage != language else { return }
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                        languageManager.setLanguage(language)
                    } label: {
                        HStack(spacing: LayoutMetrics.spacingMedium) {
                            // Custom Script / Locale Badge Icon
                            localeBadge(for: language, isSelected: language == currentLang)

                            VStack(alignment: .leading, spacing: LayoutMetrics.spacingMicro) {
                                Text(language.displayName(in: currentLang))
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)

                                Text(language.nativeDisplayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if language == currentLang {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(language.displayName(in: currentLang)), \(language.nativeDisplayName)")
                    .accessibilityAddTraits(language == currentLang ? [.isButton, .isSelected] : .isButton)
                }
            } footer: {
                Text(AppLocalization.string("profile_language_description", language: currentLang))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, LayoutMetrics.spacingMicro)
            }
        }
        .navigationTitle(AppLocalization.string("profile_language_setting", language: currentLang))
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(AppColors.screenBackground)
        .environment(\.locale, currentLang.locale)
        .id(currentLang)
    }

    @ViewBuilder
    private func localeBadge(for language: AppLanguage, isSelected: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusSmall, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.15) : AppColors.cardSurface)
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusSmall, style: .continuous)
                        .strokeBorder(isSelected ? Color.accentColor.opacity(0.5) : AppColors.cardBorder, lineWidth: 1)
                )

            Text(language.scriptSymbol)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? Color.accentColor : .primary)
        }
        .frame(width: 40, height: 40)
    }
}

#Preview("LanguageSettingsView") {
    NavigationStack {
        LanguageSettingsView()
    }
    .environment(\.languageManager, LanguageManager())
}
