//
//  AppLocalization.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation

public enum AppLocalization {
    private static let languageDefaultsKey = "app_language"

    public static var currentLanguageCode: String {
        UserDefaults.standard.string(forKey: languageDefaultsKey) ?? "en"
    }

    public static func bundle(for languageCode: String) -> Bundle {
        let candidateCodes: [String]
        if languageCode == "my" {
            candidateCodes = ["my", "my-MM", "my_MM", "my-ZG"]
        } else if languageCode == "en" {
            candidateCodes = ["en", "en-US", "en_US", "Base"]
        } else {
            candidateCodes = [languageCode]
        }

        for code in candidateCodes {
            if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                return bundle
            }
        }
        return Bundle.main
    }

    public static func string(
        _ key: String,
        defaultValue: String? = nil,
        language: AppLanguage? = nil
    ) -> String {
        let code = language?.rawValue ?? currentLanguageCode
        let targetBundle = bundle(for: code)

        let localized = targetBundle.localizedString(forKey: key, value: nil, table: nil)
        if localized != key {
            return localized
        }

        let fallback = String(localized: String.LocalizationValue(key), bundle: targetBundle)
        if fallback != key {
            return fallback
        }

        return defaultValue ?? key
    }
}
