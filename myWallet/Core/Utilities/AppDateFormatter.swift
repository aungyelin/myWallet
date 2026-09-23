//
//  AppDateFormatter.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation

public enum AppDateFormatter {
    
    private static let internationalReceiptFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "d MMM yyyy, h:mm a"
        return formatter
    }()
    
    public static func formatReceiptDate(_ date: Date) -> String {
        internationalReceiptFormatter.string(from: date)
    }

    public static func formatDateTime(_ date: Date) -> String {
        internationalReceiptFormatter.string(from: date)
    }

    /// Formats a date using international Gregorian calendar with customizable date and time styles.
    public static func format(
        _ date: Date,
        dateStyle: DateFormatter.Style = .medium,
        timeStyle: DateFormatter.Style = .short
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: date)
    }
    
}
