//
//  TopUpCheckoutParams.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation

public struct TopUpCheckoutParams: Hashable, Sendable {
    public let phone: String
    public let operatorType: TelecomOperator
    public let planTitle: String
    public let amount: Double
    public let fee: Double
    
    public init(
        phone: String,
        operatorType: TelecomOperator,
        planTitle: String,
        amount: Double,
        fee: Double = 0.0
    ) {
        self.phone = phone
        self.operatorType = operatorType
        self.planTitle = planTitle
        self.amount = amount
        self.fee = fee
    }
}
