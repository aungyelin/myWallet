//
//  TransactionRepositoryTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import Testing
import Foundation
import SwiftData
@testable import myWallet

@Suite("TransactionRepository Tests")
@MainActor
struct TransactionRepositoryTests {
    
    @Test("Saves and fetches transactions sorted by date descending")
    func saveAndFetchSorted() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TransactionRepository(modelContext: container.mainContext)
        
        let olderDate = Date().addingTimeInterval(-3600)
        let newerDate = Date()
        
        let txn1 = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks",
            amount: 1000,
            date: olderDate
        )
        let txn2 = TransactionHistory.createTransfer(
            accountOrPhone: "09770000002",
            recipientName: "Daw Mya",
            amount: 5000,
            date: newerDate
        )
        
        try repository.saveTransaction(txn1)
        try repository.saveTransaction(txn2)
        
        let all = try repository.getTransactions()
        #expect(all.count == 2)
        #expect(all.first?.referenceNumber == txn2.referenceNumber) // Newer date first
        #expect(all.last?.referenceNumber == txn1.referenceNumber)
    }

    @Test("Filters transactions by telecom operator")
    func filterByOperator() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TransactionRepository(modelContext: container.mainContext)
        
        let mptTxn = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks",
            amount: 1000
        )
        let atomTxn = TransactionHistory.createTopUp(
            mobileNumber: "09770000002",
            operatorName: "ATOM",
            planDetails: "2,000 Ks",
            amount: 2000
        )
        
        try repository.saveTransaction(mptTxn)
        try repository.saveTransaction(atomTxn)
        
        let mptResults = try repository.getTransactions(operatorFilter: .mpt)
        #expect(mptResults.count == 1)
        #expect(mptResults.first?.operatorName == "MPT")
        
        let allResults = try repository.getTransactions(operatorFilter: nil)
        #expect(allResults.count == 2)
    }

    @Test("Filters transactions by type and status")
    func filterByTypeAndStatus() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TransactionRepository(modelContext: container.mainContext)
        
        let topUp = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks",
            amount: 1000,
            status: .success
        )
        let failedTransfer = TransactionHistory.createTransfer(
            accountOrPhone: "09770000002",
            recipientName: "U Ba",
            amount: 10000,
            status: .failed
        )
        let pendingPayment = TransactionHistory.createPayment(
            merchantId: "M-123",
            merchantName: "City Mart",
            amount: 25000,
            status: .pending
        )
        
        try repository.saveTransaction(topUp)
        try repository.saveTransaction(failedTransfer)
        try repository.saveTransaction(pendingPayment)
        
        let onlyTopUps = try repository.getTransactions(typeFilter: .topUp)
        #expect(onlyTopUps.count == 1)
        #expect(onlyTopUps.first?.parsedType == .topUp)
        
        let onlyFailed = try repository.getTransactions(statusFilter: .failed)
        #expect(onlyFailed.count == 1)
        #expect(onlyFailed.first?.parsedStatus == .failed)
    }

    @Test("Searches transactions across reference, phone, counterparty, and remarks")
    func searchAcrossFields() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TransactionRepository(modelContext: container.mainContext)
        
        let txn1 = TransactionHistory.createTopUp(
            mobileNumber: "09250123456",
            operatorName: "MPT",
            planDetails: "Data 1GB",
            amount: 1500,
            remark: "Office Top-Up"
        )
        let txn2 = TransactionHistory.createPayment(
            merchantId: "MERCH-999",
            merchantName: "Ocean Supercenter",
            amount: 45000,
            remark: "Weekly Groceries"
        )
        
        try repository.saveTransaction(txn1)
        try repository.saveTransaction(txn2)
        
        // Search by phone
        let phoneMatch = try repository.getTransactions(query: "09250123456")
        #expect(phoneMatch.count == 1)
        #expect(phoneMatch.first?.mobileNumber == "09250123456")
        
        // Search by remark
        let remarkMatch = try repository.getTransactions(query: "Groceries")
        #expect(remarkMatch.count == 1)
        #expect(remarkMatch.first?.remark == "Weekly Groceries")
        
        // Search by merchant name
        let merchantMatch = try repository.getTransactions(query: "Ocean")
        #expect(merchantMatch.count == 1)
        #expect(merchantMatch.first?.recipientName == "Ocean Supercenter")
        
        // Search with no match
        let noMatch = try repository.getTransactions(query: "NonExistentQuery")
        #expect(noMatch.isEmpty)
    }

    @Test("Filters transactions by date range boundaries")
    func filterByDateRange() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TransactionRepository(modelContext: container.mainContext)
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()

        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: now)!
        let fortyDaysAgo = calendar.date(byAdding: .day, value: -40, to: now)!

        let txnRecent = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks",
            amount: 1000,
            date: threeDaysAgo
        )
        let txnMedium = TransactionHistory.createTopUp(
            mobileNumber: "09250000002",
            operatorName: "MPT",
            planDetails: "2,000 Ks",
            amount: 2000,
            date: tenDaysAgo
        )
        let txnOld = TransactionHistory.createTopUp(
            mobileNumber: "09250000003",
            operatorName: "MPT",
            planDetails: "3,000 Ks",
            amount: 3000,
            date: fortyDaysAgo
        )

        try repository.saveTransaction(txnRecent)
        try repository.saveTransaction(txnMedium)
        try repository.saveTransaction(txnOld)

        // Last 7 days filter: should only include txnRecent
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let last7DaysResults = try repository.getTransactions(startDate: sevenDaysAgo, endDate: now)
        #expect(last7DaysResults.count == 1)
        #expect(last7DaysResults.first?.referenceNumber == txnRecent.referenceNumber)

        // Last 30 days filter: should include txnRecent and txnMedium
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
        let last30DaysResults = try repository.getTransactions(startDate: thirtyDaysAgo, endDate: now)
        #expect(last30DaysResults.count == 2)

        // All time
        let allResults = try repository.getTransactions()
        #expect(allResults.count == 3)
    }

    @Test("Fetches single transaction by reference number")
    func getTransactionByReferenceNumber() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let repository = TransactionRepository(modelContext: container.mainContext)

        let txn = TransactionHistory.createTopUp(
            mobileNumber: "09250000001",
            operatorName: "MPT",
            planDetails: "1,000 Ks",
            amount: 1000,
            referenceNumber: "20260923-112233"
        )
        try repository.saveTransaction(txn)

        let found = try repository.getTransaction(by: "20260923-112233")
        #expect(found != nil)
        #expect(found?.referenceNumber == "20260923-112233")
        #expect(found?.mobileNumber == "09250000001")

        let notFound = try repository.getTransaction(by: "NON-EXISTENT")
        #expect(notFound == nil)
    }
    
}
