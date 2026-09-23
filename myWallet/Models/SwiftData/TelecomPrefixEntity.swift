//
//  TelecomPrefixEntity.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData

/// SwiftData persistent entity representing telecom mobile numbering prefixes and operator mappings.
@Model
public final class TelecomPrefixEntity {
    /// Unique identifier for the prefix entity.
    public var id: UUID
    /// Dialing prefix (e.g. "092", "097", "0989").
    @Attribute(.unique) public var prefix: String
    /// Canonical telecom operator code/identifier (e.g. "MPT", "ATOM", "U9", "Mytel").
    public var operatorName: String
    /// Localized or branded display name of the telecom operator.
    public var brandDisplayName: String
    /// Asset catalog or symbol name for the telecom operator's brand logo.
    public var brandLogoName: String

    public init(
        id: UUID = UUID(),
        prefix: String,
        operatorName: String,
        brandDisplayName: String,
        brandLogoName: String
    ) {
        self.id = id
        self.prefix = prefix
        self.operatorName = operatorName
        self.brandDisplayName = brandDisplayName
        self.brandLogoName = brandLogoName
    }

    public var operatorType: TelecomOperator {
        TelecomOperator.from(rawName: operatorName)
    }
}
