//
//  TopUpReceiptParams.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation

public struct TopUpReceiptParams: Hashable, Sendable {
    public let referenceNumber: String
    public let phone: String
    public let operatorType: TelecomOperator
    public let planTitle: String
    public let amount: Double
    public let fee: Double
    public let timestamp: Date
    
    public init(
        referenceNumber: String,
        phone: String,
        operatorType: TelecomOperator,
        planTitle: String,
        amount: Double,
        fee: Double = 0.0,
        timestamp: Date = Date()
    ) {
        self.referenceNumber = referenceNumber
        self.phone = phone
        self.operatorType = operatorType
        self.planTitle = planTitle
        self.amount = amount
        self.fee = fee
        self.timestamp = timestamp
    }
}
