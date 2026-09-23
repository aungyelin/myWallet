//
//  TransactionDateFilter.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation

public enum TransactionDateFilter: Hashable, Sendable {
    case all
    case today
    case last7Days
    case last30Days
    case custom(start: Date, end: Date)

    public var localizedTitle: String {
        switch self {
        case .all:
            return AppLocalization.string("filter_date_all", defaultValue: "All Time")
        case .today:
            return AppLocalization.string("filter_date_today", defaultValue: "Today")
        case .last7Days:
            return AppLocalization.string("filter_date_7days", defaultValue: "Last 7 Days")
        case .last30Days:
            return AppLocalization.string("filter_date_30days", defaultValue: "Last 30 Days")
        case .custom:
            return AppLocalization.string("filter_date_custom", defaultValue: "Custom Range")
        }
    }

    /// Computes boundary dates (start of day, end of day) in the Gregorian calendar.
    public func dateBoundaries(
        relativeTo now: Date = Date(),
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> (start: Date?, end: Date?) {
        switch self {
        case .all:
            return (nil, nil)
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)
            return (start, end)
        case .last7Days:
            guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) else {
                return (nil, nil)
            }
            let start = calendar.startOfDay(for: sevenDaysAgo)
            let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)
            return (start, end)
        case .last30Days:
            guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) else {
                return (nil, nil)
            }
            let start = calendar.startOfDay(for: thirtyDaysAgo)
            let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)
            return (start, end)
        case .custom(let customStart, let customEnd):
            let start = calendar.startOfDay(for: customStart)
            let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: customEnd)
            return (start, end ?? customEnd)
        }
    }
}
