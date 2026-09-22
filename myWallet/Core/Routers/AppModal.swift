//
//  AppModal.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation

public enum AppSheet: Hashable, Identifiable, Sendable {
    case transactionFilter
    case transactionDetail(referenceNumber: String)
    
    public var id: String {
        switch self {
        case .transactionFilter:
            return "transactionFilter"
        case .transactionDetail(let ref):
            return "transactionDetail_\(ref)"
        }
    }
}

public enum AppCover: Hashable, Identifiable, Sendable {
    case topUpSuccess(TopUpReceiptParams)
    
    public var id: String {
        switch self {
        case .topUpSuccess(let params):
            return "topUpSuccess_\(params.referenceNumber)"
        }
    }
}
