//
//  TelecomPrefixDTO.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation

public struct TelecomPrefixDTO: Codable, Sendable, Equatable {
    public let prefix: String
    public let operatorName: String
    public let brandDisplayName: String
    public let brandLogoName: String

    public init(
        prefix: String,
        operatorName: String,
        brandDisplayName: String,
        brandLogoName: String
    ) {
        self.prefix = prefix
        self.operatorName = operatorName
        self.brandDisplayName = brandDisplayName
        self.brandLogoName = brandLogoName
    }

    public func toEntity() -> TelecomPrefixEntity {
        TelecomPrefixEntity(
            prefix: prefix,
            operatorName: operatorName,
            brandDisplayName: brandDisplayName,
            brandLogoName: brandLogoName
        )
    }
}
