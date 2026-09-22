//
//  TransactionHistoryDTO.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation

public struct TransactionHistoryDTO: Codable, Sendable, Equatable {
    public let id: UUID
    public let transactionType: String
    public let status: String
    public let amount: Double
    public let date: Date
    public let referenceNumber: String
    public let fee: Double
    public let counterparty: String
    public let recipientName: String?
    public let remark: String?
    public let mobileNumber: String?
    public let operatorName: String?
    public let planDetails: String?

    public init(
        id: UUID = UUID(),
        transactionType: String,
        status: String,
        amount: Double,
        date: Date,
        referenceNumber: String,
        fee: Double = 0.0,
        counterparty: String,
        recipientName: String? = nil,
        remark: String? = nil,
        mobileNumber: String? = nil,
        operatorName: String? = nil,
        planDetails: String? = nil
    ) {
        self.id = id
        self.transactionType = transactionType
        self.status = status
        self.amount = amount
        self.date = date
        self.referenceNumber = referenceNumber
        self.fee = fee
        self.counterparty = counterparty
        self.recipientName = recipientName
        self.remark = remark
        self.mobileNumber = mobileNumber
        self.operatorName = operatorName
        self.planDetails = planDetails
    }

    public func toEntity() -> TransactionHistory {
        TransactionHistory(
            id: id,
            transactionType: TransactionType(rawValue: transactionType) ?? .topUp,
            status: TransactionStatus(rawValue: status) ?? .success,
            amount: amount,
            date: date,
            referenceNumber: referenceNumber,
            fee: fee,
            counterparty: counterparty,
            recipientName: recipientName,
            remark: remark,
            mobileNumber: mobileNumber,
            operatorName: operatorName,
            planDetails: planDetails
        )
    }
}
