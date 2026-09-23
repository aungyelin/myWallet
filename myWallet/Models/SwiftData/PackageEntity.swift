//
//  PackageEntity.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData

/// SwiftData persistent entity representing denominations and data packages offered by telecom operators.
@Model
public final class PackageEntity {
    /// Unique identifier for the package (e.g. "pkg_mpt_denom_1000").
    @Attribute(.unique) public var id: String
    /// Associated telecom operator name (e.g. "MPT", "ATOM", "U9", "Mytel").
    public var operatorName: String
    /// Category of the item: "Data", "Voice", "Auto Renewal", "Entertainment", "SMS", "Roaming", etc.
    public var category: String
    /// Pack group identifier (e.g. "A Kyite Kyi", "Data Carry Plus", "Unlimited Packs").
    public var packGroup: String
    /// Display name of the package or denomination.
    public var name: String
    /// Detailed description of package terms, quota, or talk-time.
    public var packageDescription: String
    /// Price in Myanmar Kyats (MMK).
    public var amount: Double
    /// Validity period in days (0 for standard balance without expiration).
    public var validityDays: Int
    /// Human-readable validity display text (e.g. "30 Days", "7 Days").
    public var validityText: String
    /// Optional data volume or quota allowance (e.g. "1 GB", "2.5 GB").
    public var dataAllowance: String?
    /// Whether this package should display a promotional or popular badge.
    public var isPopular: Bool

    public init(
        id: String,
        operatorName: String,
        category: String,
        packGroup: String = "",
        name: String,
        packageDescription: String,
        amount: Double,
        validityDays: Int,
        validityText: String,
        dataAllowance: String? = nil,
        isPopular: Bool = false
    ) {
        self.id = id
        self.operatorName = operatorName
        self.category = category
        self.packGroup = packGroup
        self.name = name
        self.packageDescription = packageDescription
        self.amount = amount
        self.validityDays = validityDays
        self.validityText = validityText
        self.dataAllowance = dataAllowance
        self.isPopular = isPopular
    }

    public var operatorType: TelecomOperator {
        TelecomOperator.from(rawName: operatorName)
    }
}
