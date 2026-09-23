//
//  TopUpRechargeResponseDTO.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation

public struct TopUpRechargeResponseDTO: Codable, Sendable {
    public let referenceNumber: String
    public let status: String
    public let timestamp: Date
    public let mobileNumber: String
    public let operatorName: String
    public let planDetails: String
    public let amount: Double
    public let fee: Double

    public init(
        referenceNumber: String,
        status: String = Constants.Transaction.statusSuccess,
        timestamp: Date = Date(),
        mobileNumber: String,
        operatorName: String,
        planDetails: String,
        amount: Double,
        fee: Double = 0.0
    ) {
        self.referenceNumber = referenceNumber
        self.status = status
        self.timestamp = timestamp
        self.mobileNumber = mobileNumber
        self.operatorName = operatorName
        self.planDetails = planDetails
        self.amount = amount
        self.fee = fee
    }
}
