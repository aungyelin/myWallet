//
//  AppTheme.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum AppTheme: String, CaseIterable, Identifiable, Sendable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .system:
            return String(localized: "profile_theme_system")
        case .light:
            return String(localized: "profile_theme_light")
        case .dark:
            return String(localized: "profile_theme_dark")
        }
    }
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    #if canImport(UIKit)
    /// The corresponding UIKit `UIUserInterfaceStyle` to ensure reliable window-level style enforcement.
    public var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    /// Applies the window-level interface style override across all active window scenes.
    @MainActor
    public static func applyUserInterfaceStyle(_ theme: AppTheme) {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        for scene in scenes {
            for window in scene.windows {
                window.overrideUserInterfaceStyle = theme.userInterfaceStyle
            }
        }
    }
    #endif
    
    public var iconName: String {
        switch self {
        case .system:
            return "gearshape"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}
