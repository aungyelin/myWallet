//
//  LanguageManager.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
public final class LanguageManager: LanguageManagerProtocol {
    
    public static let shared = LanguageManager()

    private let userDefaultsKey = "app_language"
    private let userDefaults: UserDefaults

    public private(set) var currentLanguage: AppLanguage

    public init(defaults: UserDefaults = .standard) {
        self.userDefaults = defaults
        let savedValue = defaults.string(forKey: userDefaultsKey) ?? AppLanguage.english.rawValue
        self.currentLanguage = AppLanguage(rawValue: savedValue) ?? .english
    }

    public func setLanguage(_ language: AppLanguage) {
        guard currentLanguage != language else { return }
        currentLanguage = language
        userDefaults.set(language.rawValue, forKey: userDefaultsKey)
        userDefaults.set([language.rawValue], forKey: "AppleLanguages")
    }
    
}

@MainActor
private struct LanguageManagerKey: EnvironmentKey {
    @MainActor static let defaultValue: any LanguageManagerProtocol = LanguageManager.shared
}

extension EnvironmentValues {
    public var languageManager: any LanguageManagerProtocol {
        get { self[LanguageManagerKey.self] }
        set { self[LanguageManagerKey.self] = newValue }
    }
}
