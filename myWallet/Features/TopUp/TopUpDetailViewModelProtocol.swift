//
//  TopUpDetailViewModelProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation

@MainActor
public protocol TopUpDetailViewModelProtocol: AnyObject {
    
    var params: TopUpCheckoutParams { get }
    var isProcessing: Bool { get }
    var errorMessage: String? { get }

    func confirmPayment(router: (any AppRouterProtocol)?) async
    
}
