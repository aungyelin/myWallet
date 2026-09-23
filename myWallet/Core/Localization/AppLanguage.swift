//
//  AppLanguage.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case burmese = "my"

    public var id: String { rawValue }

    public var locale: Locale {
        Locale(identifier: rawValue)
    }

    public var scriptSymbol: String {
        switch self {
        case .english:
            return "EN"
        case .burmese:
            return "က"
        }
    }

    public var systemIconName: String {
        switch self {
        case .english:
            return "textformat.abc"
        case .burmese:
            return "character.book.closed"
        }
    }

    public func displayName(in language: AppLanguage) -> String {
        switch self {
        case .english:
            return AppLocalization.string("language_english", language: language)
        case .burmese:
            return AppLocalization.string("language_burmese", language: language)
        }
    }

    public var displayName: String {
        displayName(in: AppLanguage(rawValue: AppLocalization.currentLanguageCode) ?? .english)
    }

    public var nativeDisplayName: String {
        switch self {
        case .english:
            return "English"
        case .burmese:
            return "မြန်မာစာ"
        }
    }
}
