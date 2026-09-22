//
//  TelecomOperator.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftUI

/// Canonical telecom operator identifiers recognized by the Myanmar telecommunications numbering plan.
public enum TelecomOperator: String, CaseIterable, Codable, Sendable {
    case mpt = "MPT"
    case atom = "ATOM"
    case ooredoo = "Ooredoo"
    case mytel = "Mytel"
    case unknown = "Unknown"
    
    /// User-facing display title for the operator.
    public var displayName: String {
        switch self {
        case .mpt:
            return String(localized: "operator_mpt", defaultValue: "MPT")
        case .atom:
            return String(localized: "operator_atom", defaultValue: "ATOM")
        case .ooredoo:
            return String(localized: "operator_ooredoo", defaultValue: "Ooredoo")
        case .mytel:
            return String(localized: "operator_mytel", defaultValue: "Mytel")
        case .unknown:
            return String(localized: "operator_unknown", defaultValue: "Unknown Operator")
        }
    }

    /// Semantic brand accent color for UI badges, active borders, and card accents.
    public var brandColor: Color {
        switch self {
        case .mpt:
            return .blue
        case .atom:
            return .cyan
        case .ooredoo:
            return .red
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
        case .ooredoo:
            return "red"
        case .mytel:
            return "orange"
        case .unknown:
            return "gray"
        }
    }
    
    /// Default SF Symbol or asset logo name representing the telecom brand.
    public var logoImageName: String {
        switch self {
        case .mpt:
            return "antenna.radiowaves.left.and.right"
        case .atom:
            return "bolt.horizontal.circle.fill"
        case .ooredoo:
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
