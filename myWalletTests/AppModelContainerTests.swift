//
//  AppModelContainerTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Testing
import Foundation
import SwiftData
@testable import myWallet

@Suite("AppModelContainer & Entity Tests")
@MainActor
struct AppModelContainerTests {
    @Test("In-memory container creates successfully with schema entities")
    func createInMemoryContainer() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        #expect(container.schema.entities.count == 3)
    }

    @Test("TransactionHistory top-up factory creates valid entity with optional fields")
    func topUpFactoryCreatesValidEntity() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext

        let topUp = TransactionHistory.createTopUp(
            mobileNumber: "09250000000",
            operatorName: "MPT",
            planDetails: "1,000 Ks Top-Up",
            amount: 1000.0,
            status: .success,
            fee: 0.0,
            remark: "Family top-up"
        )
        context.insert(topUp)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<TransactionHistory>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.parsedType == .topUp)
        #expect(fetched.first?.parsedStatus == .success)
        #expect(fetched.first?.mobileNumber == "09250000000")
        #expect(fetched.first?.operatorName == "MPT")
        #expect(fetched.first?.planDetails == "1,000 Ks Top-Up")
        #expect(fetched.first?.counterparty == "09250000000")
    }

    @Test("TransactionHistory transfer factory sets nil top-up fields")
    func transferFactorySetsNilTopUpFields() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext

        let transfer = TransactionHistory.createTransfer(
            accountOrPhone: "200918273645",
            recipientName: "Daw Mya",
            amount: 50000.0,
            status: .success,
            remark: "Monthly contribution"
        )
        context.insert(transfer)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<TransactionHistory>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.parsedType == .transfer)
        #expect(fetched.first?.counterparty == "200918273645")
        #expect(fetched.first?.recipientName == "Daw Mya")
        #expect(fetched.first?.operatorName == nil)
        #expect(fetched.first?.planDetails == nil)
        #expect(fetched.first?.mobileNumber == nil)
        #expect(fetched.first?.remark == "Monthly contribution")
    }

    @Test("TransactionHistory payment factory sets nil top-up fields")
    func paymentFactorySetsNilTopUpFields() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext

        let payment = TransactionHistory.createPayment(
            merchantId: "MERCHANT-01",
            merchantName: "City Mart",
            amount: 15000.0,
            status: .success,
            remark: "Groceries"
        )
        context.insert(payment)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<TransactionHistory>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.parsedType == .payment)
        #expect(fetched.first?.counterparty == "MERCHANT-01")
        #expect(fetched.first?.recipientName == "City Mart")
        #expect(fetched.first?.operatorName == nil)
        #expect(fetched.first?.planDetails == nil)
        #expect(fetched.first?.mobileNumber == nil)
    }

    @Test("PackageEntity and TelecomPrefixEntity persist and retrieve correctly")
    func persistAuxiliaryEntities() throws {
        let container = try AppModelContainer.createInMemoryContainer()
        let context = container.mainContext

        let prefix = TelecomPrefixEntity(
            prefix: "092",
            operatorName: "MPT",
            brandDisplayName: "MPT",
            brandLogoName: "mpt_logo"
        )
        let package = PackageEntity(
            id: "pkg_test_1",
            operatorName: "MPT",
            category: "denomination",
            name: "1,000 Ks",
            packageDescription: "Recharge",
            amount: 1000.0,
            validityDays: 0,
            validityText: "No Expiry"
        )

        context.insert(prefix)
        context.insert(package)
        try context.save()

        let fetchedPrefixes = try context.fetch(FetchDescriptor<TelecomPrefixEntity>())
        let fetchedPackages = try context.fetch(FetchDescriptor<PackageEntity>())

        #expect(fetchedPrefixes.count == 1)
        #expect(fetchedPrefixes.first?.prefix == "092")
        #expect(fetchedPackages.count == 1)
        #expect(fetchedPackages.first?.id == "pkg_test_1")
    }
}
