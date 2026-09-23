//
//  ThemeManager.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI
import Observation
#if canImport(UIKit)
import UIKit
#endif

@Observable
@MainActor
public final class ThemeManager: ThemeManagerProtocol {
    
    public static let shared = ThemeManager()
    
    private let userDefaultsKey = "app_theme"
    private let userDefaults: UserDefaults
    
    public private(set) var currentTheme: AppTheme
    
    public init(defaults: UserDefaults = .standard) {
        self.userDefaults = defaults
        let savedRawValue = defaults.string(forKey: userDefaultsKey) ?? AppTheme.system.rawValue
        let initialTheme = AppTheme(rawValue: savedRawValue) ?? .system
        self.currentTheme = initialTheme
        applyTheme(initialTheme)
    }
    
    public func setTheme(_ theme: AppTheme) {
        guard currentTheme != theme else { return }
        currentTheme = theme
        userDefaults.set(theme.rawValue, forKey: userDefaultsKey)
        applyTheme(theme)
    }
    
    /// Applies the window-level interface style override across all active window scenes.
    private func applyTheme(_ theme: AppTheme) {
        #if canImport(UIKit)
        AppTheme.applyUserInterfaceStyle(theme)
        #endif
    }
    
}

// MARK: - SwiftUI Environment Integration

private struct ThemeManagerKey: EnvironmentKey {
    @MainActor static let defaultValue: ThemeManager = ThemeManager.shared
}

extension EnvironmentValues {
    public var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
