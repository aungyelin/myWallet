//
//  TransactionStatus.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation

public enum TransactionStatus: String, Codable, CaseIterable, Sendable {
    case success = "success"
    case pending = "pending"
    case failed = "failed"

    public var localizedTitle: String {
        switch self {
        case .success:
            return String(localized: "status_success", defaultValue: "Success")
        case .pending:
            return String(localized: "status_pending", defaultValue: "Pending")
        case .failed:
            return String(localized: "status_failed", defaultValue: "Failed")
        }
    }
}
