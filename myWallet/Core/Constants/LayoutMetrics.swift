//
//  LayoutMetrics.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation

/// Centralized UI layout metrics, spacing, and sizing constants.
public enum LayoutMetrics {
    
    // MARK: - Spacing & Paddings
    public static let spacingMicro: CGFloat = 4
    public static let spacingSmall: CGFloat = 8
    public static let spacingMedium: CGFloat = 12
    public static let spacingStandard: CGFloat = 16
    public static let spacingLarge: CGFloat = 24
    public static let spacingExtraLarge: CGFloat = 32

    // MARK: - Corner Radius
    public static let cornerRadiusSmall: CGFloat = 8
    public static let cornerRadiusMedium: CGFloat = 12
    public static let cornerRadiusLarge: CGFloat = 16
    public static let cornerRadiusPill: CGFloat = 24

    // MARK: - Component Sizing
    public static let primaryButtonHeight: CGFloat = 52
    public static let secondaryButtonHeight: CGFloat = 44
    public static let smallButtonHeight: CGFloat = 36
    public static let iconSizeSmall: CGFloat = 16
    public static let iconSizeMedium: CGFloat = 24
    public static let iconSizeLarge: CGFloat = 32
    public static let tileIconSize: CGFloat = 40
    public static let avatarSize: CGFloat = 64

    // MARK: - Responsive & Form-Factor Constraints
    /// The maximum readable content width enforced on iPad (Regular size-class).
    public static let maxContentWidth: CGFloat = 600
    public static let maxModalWidth: CGFloat = 540
    public static let minGridTileWidth: CGFloat = 72
    public static let minPackageCardWidth: CGFloat = 150
    
}
