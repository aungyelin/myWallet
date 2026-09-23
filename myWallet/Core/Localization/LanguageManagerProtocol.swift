//
//  LanguageManagerProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation

@MainActor
public protocol LanguageManagerProtocol: AnyObject, Observable {
    
    var currentLanguage: AppLanguage { get }
    func setLanguage(_ language: AppLanguage)
    
}
