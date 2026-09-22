//
//  PackageDTO.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation

public struct PackageDTO: Codable, Sendable, Equatable {
    public let id: String
    public let operatorName: String
    public let category: String
    public let name: String
    public let packageDescription: String
    public let amount: Double
    public let validityDays: Int
    public let validityText: String
    public let dataAllowance: String?
    public let isPopular: Bool

    public init(
        id: String,
        operatorName: String,
        category: String,
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
        self.name = name
        self.packageDescription = packageDescription
        self.amount = amount
        self.validityDays = validityDays
        self.validityText = validityText
        self.dataAllowance = dataAllowance
        self.isPopular = isPopular
    }

    public func toEntity() -> PackageEntity {
        PackageEntity(
            id: id,
            operatorName: operatorName,
            category: category,
            name: name,
            packageDescription: packageDescription,
            amount: amount,
            validityDays: validityDays,
            validityText: validityText,
            dataAllowance: dataAllowance,
            isPopular: isPopular
        )
    }
}
