//
//  TransactionStatus.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftUI

public enum TransactionStatus: String, Codable, CaseIterable, Sendable {
    case success = "success"
    case pending = "pending"
    case failed = "failed"

    public var localizedTitle: String {
        switch self {
        case .success:
            return AppLocalization.string("status_success", defaultValue: "Success")
        case .pending:
            return AppLocalization.string("status_pending", defaultValue: "Pending")
        case .failed:
            return AppLocalization.string("status_failed", defaultValue: "Failed")
        }
    }

    public var statusColor: Color {
        switch self {
        case .success:
            return .green
        case .pending:
            return .orange
        case .failed:
            return .red
        }
    }

    public var systemIconName: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .pending:
            return "clock.fill"
        case .failed:
            return "xmark.circle.fill"
        }
    }
}
