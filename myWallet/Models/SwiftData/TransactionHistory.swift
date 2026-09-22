//
//  TransactionHistory.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData

/// Persistent entity representing all types of banking transactions (Top-Up, Transfer, Payment).
@Model
public final class TransactionHistory {
    /// Unique identifier for the transaction.
    public var id: UUID
    /// Raw string value corresponding to `TransactionType`.
    public var transactionType: String
    /// Raw string value corresponding to `TransactionStatus`.
    public var status: String
    /// Monetary amount of the transaction.
    public var amount: Double
    /// Timestamp when the transaction took place.
    public var date: Date
    /// Formatted business reference number (e.g. TXN-...).
    public var referenceNumber: String
    /// Transaction fee charged (default: 0.0).
    public var fee: Double
    /// Target destination identifier: phone number for top-up, account number for transfer, merchant ID for payment.
    public var counterparty: String
    /// Optional counterparty display name (e.g. contact name or merchant name).
    public var recipientName: String?
    /// Optional transaction remarks, memo, or invoice details.
    public var remark: String?

    // MARK: - Top-Up Specific Metadata (nil for other transaction types)
    /// Target mobile phone number for mobile top-up recharges.
    public var mobileNumber: String?
    /// Telecom operator name (e.g. MPT, ATOM, U9, Mytel).
    public var operatorName: String?
    /// Description of the recharge denomination or data package.
    public var planDetails: String?

    public init(
        id: UUID = UUID(),
        transactionType: TransactionType = .topUp,
        status: TransactionStatus = .success,
        amount: Double,
        date: Date = Date(),
        referenceNumber: String = ReferenceNumberGenerator.generate(),
        fee: Double = 0.0,
        counterparty: String = "",
        recipientName: String? = nil,
        remark: String? = nil,
        mobileNumber: String? = nil,
        operatorName: String? = nil,
        planDetails: String? = nil
    ) {
        self.id = id
        self.transactionType = transactionType.rawValue
        self.status = status.rawValue
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

    // MARK: - Computed Properties
    public var parsedType: TransactionType {
        TransactionType(rawValue: transactionType) ?? .topUp
    }

    public var parsedStatus: TransactionStatus {
        TransactionStatus(rawValue: status) ?? .success
    }

    public var operatorType: TelecomOperator {
        TelecomOperator.from(rawName: operatorName)
    }

    // MARK: - Factory Methods
    /// Creates a mobile top-up transaction record.
    public static func createTopUp(
        id: UUID = UUID(),
        mobileNumber: String,
        operatorName: String,
        planDetails: String,
        amount: Double,
        status: TransactionStatus = .success,
        fee: Double = 0.0,
        remark: String? = nil,
        date: Date = Date(),
        referenceNumber: String? = nil
    ) -> TransactionHistory {
        let reference = referenceNumber ?? ReferenceNumberGenerator.generate(date: date)
        return TransactionHistory(
            id: id,
            transactionType: .topUp,
            status: status,
            amount: amount,
            date: date,
            referenceNumber: reference,
            fee: fee,
            counterparty: mobileNumber,
            recipientName: nil,
            remark: remark,
            mobileNumber: mobileNumber,
            operatorName: operatorName,
            planDetails: planDetails
        )
    }

    /// Creates a wallet transfer transaction record.
    public static func createTransfer(
        id: UUID = UUID(),
        accountOrPhone: String,
        recipientName: String,
        amount: Double,
        status: TransactionStatus = .success,
        fee: Double = 0.0,
        remark: String? = nil,
        date: Date = Date(),
        referenceNumber: String? = nil
    ) -> TransactionHistory {
        let reference = referenceNumber ?? ReferenceNumberGenerator.generate(date: date)
        return TransactionHistory(
            id: id,
            transactionType: .transfer,
            status: status,
            amount: amount,
            date: date,
            referenceNumber: reference,
            fee: fee,
            counterparty: accountOrPhone,
            recipientName: recipientName,
            remark: remark,
            mobileNumber: nil,
            operatorName: nil,
            planDetails: nil
        )
    }

    /// Creates a merchant payment transaction record.
    public static func createPayment(
        id: UUID = UUID(),
        merchantId: String,
        merchantName: String,
        amount: Double,
        status: TransactionStatus = .success,
        fee: Double = 0.0,
        remark: String? = nil,
        date: Date = Date(),
        referenceNumber: String? = nil
    ) -> TransactionHistory {
        let reference = referenceNumber ?? ReferenceNumberGenerator.generate(date: date)
        return TransactionHistory(
            id: id,
            transactionType: .payment,
            status: status,
            amount: amount,
            date: date,
            referenceNumber: reference,
            fee: fee,
            counterparty: merchantId,
            recipientName: merchantName,
            remark: remark,
            mobileNumber: nil,
            operatorName: nil,
            planDetails: nil
        )
    }
}
