//
//  TelecomOperator.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftUI

public enum TelecomOperator: String, CaseIterable, Codable, Sendable {
    case mpt = "MPT"
    case atom = "ATOM"
    case u9 = "U9"
    case mytel = "Mytel"
    case unknown = "Unknown"
    
    /// User-facing display title for the operator.
    public var displayName: String {
        switch self {
        case .mpt:
            return AppLocalization.string("operator_mpt", defaultValue: "MPT")
        case .atom:
            return AppLocalization.string("operator_atom", defaultValue: "ATOM")
        case .u9:
            return AppLocalization.string("operator_u9", defaultValue: "U9")
        case .mytel:
            return AppLocalization.string("operator_mytel", defaultValue: "Mytel")
        case .unknown:
            return AppLocalization.string("operator_unknown", defaultValue: "Unknown Operator")
        }
    }

    /// Semantic brand accent color for UI badges, active borders, and card accents.
    public var brandColor: Color {
        switch self {
        case .mpt:
            return .blue
        case .atom:
            return .cyan
        case .u9:
            return Color(red: 0.88, green: 0.68, blue: 0.15)
        case .mytel:
            return .orange
        case .unknown:
            return .secondary
        }
    }
    
    /// Suggested brand accent color token name.
    public var brandColorToken: String {
        switch self {
        case .mpt:
            return "blue"
        case .atom:
            return "cyan"
        case .u9:
            return "gold"
        case .mytel:
            return "orange"
        case .unknown:
            return "gray"
        }
    }

    /// Asset catalog image set name for the telecom operator logo.
    public var logoAssetName: String? {
        switch self {
        case .mpt:
            return "mpt"
        case .atom:
            return "atom"
        case .u9:
            return "u9"
        case .mytel:
            return "mytel"
        case .unknown:
            return nil
        }
    }
    
    /// Default SF Symbol or asset logo name representing the telecom brand.
    public var logoImageName: String {
        switch self {
        case .mpt:
            return "antenna.radiowaves.left.and.right"
        case .atom:
            return "bolt.horizontal.circle.fill"
        case .u9:
            return "flame.fill"
        case .mytel:
            return "network"
        case .unknown:
            return "questionmark.circle"
        }
    }
    
    /// Safe initializer resolving from any raw or case-insensitive string.
    public static func from(rawName: String?) -> TelecomOperator {
        guard let rawName = rawName?.trimmingCharacters(in: .whitespacesAndNewlines), !rawName.isEmpty else {
            return .unknown
        }
        for op in TelecomOperator.allCases {
            if op.rawValue.caseInsensitiveCompare(rawName) == .orderedSame {
                return op
            }
        }
        return .unknown
    }
}
