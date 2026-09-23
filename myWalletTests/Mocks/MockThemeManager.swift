//
//  MockThemeManager.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation
import Observation
@testable import myWallet

/// Test spy implementing `ThemeManagerProtocol` for deterministic UI and ViewModel tests.
@Observable
@MainActor
final class MockThemeManager: ThemeManagerProtocol {
    
    var currentTheme: AppTheme = .system
    
    // Spied invocations
    var setThemeCallCount: Int = 0
    var selectedThemes: [AppTheme] = []
    
    func setTheme(_ theme: AppTheme) {
        setThemeCallCount += 1
        selectedThemes.append(theme)
        currentTheme = theme
    }
    
}
