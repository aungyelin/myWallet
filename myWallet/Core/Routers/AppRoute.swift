//
//  AppRoute.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation

public enum AppRoute: Hashable, Sendable {
    case topUp
    case topUpDetail(TopUpCheckoutParams)
    case topUpSuccess(TopUpReceiptParams)
    case transactionHistory
    case transactionDetail(referenceNumber: String)
    case themeSettings
    case languageSettings
    
    public var defaultTab: AppTab {
        switch self {
        case .themeSettings, .languageSettings:
            return .profile
        case .topUp, .topUpDetail, .topUpSuccess, .transactionHistory, .transactionDetail:
            return .home
        }
    }
}
