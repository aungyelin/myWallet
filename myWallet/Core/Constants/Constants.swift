//
//  Constants.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation

public enum Constants {
    
    /// Network latency and simulation configurations.
    public enum Network {
        public static let defaultLatencyNanoseconds: UInt64 = 600_000_000   // 0.6s
        public static let fastLatencyNanoseconds: UInt64 = 10_000_000       // 0.01s for testing
    }

    public enum Telecom {
        /// Minimum typed digits required to trigger automatic telecom detection.
        public static let minPrefixDetectionDigits: Int = 3
        public static let mpt = TelecomOperator.mpt.rawValue
        public static let atom = TelecomOperator.atom.rawValue
        public static let u9 = TelecomOperator.u9.rawValue
        public static let mytel = TelecomOperator.mytel.rawValue
        public static let unknown = TelecomOperator.unknown.rawValue
        public static let myanmarCountryCode = "+959"
        public static let localPrefix = "09"
    }

    public enum Currency {
        public static let symbol = "Ks"
        public static let code = "MMK"
    }

    public enum Transaction {
        public static let statusSuccess = "success"
        public static let statusPending = "pending"
        public static let statusFailed = "failed"
        public static let typeTopUp = "top_up"
        public static let typeTransfer = "transfer"
        public static let typePayment = "payment"
    }

    public enum ResourceFiles {
        public static let telecomPrefixes = "telecom_prefixes"
        public static let packages = "packages"
        public static let sampleTransactions = "sample_transactions"
        public static let jsonExtension = "json"
    }

    /// Logging subsystem identifiers.
    public enum Logging {
        public static let subsystem = "dev.yelinaung.myWallet"
        public static let networkCategory = "Network"
        public static let syncCategory = "DataSync"
        public static let repositoryCategory = "Repository"
    }
    
}
