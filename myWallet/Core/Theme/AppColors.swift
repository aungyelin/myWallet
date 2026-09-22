//
//  AppColors.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Centralized semantic color definitions supporting adaptive Light and Dark modes.
/// Dark mode deliberately replaces OLED true black (#000000) with a premium dark charcoal gray palette.
public enum AppColors {
    
    #if canImport(UIKit)
    /// Screen background: soft off-white/light gray in light mode, dark charcoal gray in dark mode (not pure black).
    public static let screenBackground = Color(
        uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // Premium dark charcoal gray (#161618)
                return UIColor(red: 0.086, green: 0.086, blue: 0.094, alpha: 1.0)
            default:
                return UIColor.systemGroupedBackground
            }
        }
    )
    
    /// Card and container surface: crisp white in light mode, elevated medium-dark gray in dark mode.
    public static let cardSurface = Color(
        uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // Elevated dark gray card surface (#222226)
                return UIColor(red: 0.133, green: 0.133, blue: 0.149, alpha: 1.0)
            default:
                return UIColor.secondarySystemGroupedBackground
            }
        }
    )
    
    /// Card border: subtle dynamic border providing clean edge definition.
    public static let cardBorder = Color(
        uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(white: 1.0, alpha: 0.08)
            default:
                return UIColor(white: 0.0, alpha: 0.06)
            }
        }
    )
    #else
    public static let screenBackground = Color.gray.opacity(0.1)
    public static let cardSurface = Color.white
    public static let cardBorder = Color.black.opacity(0.06)
    #endif
    
}
