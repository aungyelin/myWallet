//
//  Item.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
