//
//  ReferenceNumberGenerator.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation

public enum ReferenceNumberGenerator {
    
    public static func generate(date: Date = Date()) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let dateString = String(format: "%04d%02d%02d", year, month, day)
        let randomNumber = Int.random(in: 100_000...999_999)
        return "TXN-\(dateString)-\(randomNumber)" // (e.g. `TXN-20260922-482910`)
    }
    
}
