//
//  ThemeManagerProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation

@MainActor
public protocol ThemeManagerProtocol: AnyObject {
    
    var currentTheme: AppTheme { get }
    func setTheme(_ theme: AppTheme)
    
}
