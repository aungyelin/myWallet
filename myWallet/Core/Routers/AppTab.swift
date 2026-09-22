//
//  AppTab.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Foundation

public enum AppTab: Int, Hashable, CaseIterable, Identifiable, Sendable {
    case home = 0
    case profile = 1
    
    public var id: Int { rawValue }
}
