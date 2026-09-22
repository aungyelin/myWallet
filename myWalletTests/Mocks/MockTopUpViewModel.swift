//
//  MockTopUpViewModel.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation
@testable import myWallet

@Observable
@MainActor
public final class MockTopUpViewModel: TopUpViewModelProtocol {
    public var phoneNumber: String = ""
    public var detectedOperator: TelecomOperator = .unknown
    public var isOperatorTagVisible: Bool = false
    public var standardTopUpAmounts: [Double] = [1000, 2000, 3000]
    public var isPackagesSectionVisible: Bool = false
    public var availableCategories: [String] = []
    public var selectedCategory: String = ""
    public var packGroupsForSelectedCategory: [(packName: String, packages: [PackageEntity])] = []
    public var validationError: String?

    public var onAppearCalled: Bool = false
    public var onPhoneNumberChangedCalled: Bool = false
    public var lastSelectedAmount: Double?

    public init() {}

    public func onAppear() async {
        onAppearCalled = true
    }

    public func onPhoneNumberChanged(_ newNumber: String) async {
        onPhoneNumberChangedCalled = true
        self.phoneNumber = newNumber
    }

    public func selectCategory(_ category: String) {
        self.selectedCategory = category
    }

    public func selectTopUpAmount(_ amount: Double, router: (any AppRouterProtocol)?) {
        self.lastSelectedAmount = amount
    }

    public func selectPackage(_ package: PackageEntity, router: (any AppRouterProtocol)?) {}

    public func clearValidationError() {
        self.validationError = nil
    }
}
