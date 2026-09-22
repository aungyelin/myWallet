//
//  TopUpViewModelProtocol.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation

@MainActor
public protocol TopUpViewModelProtocol: AnyObject, Observable {
    
    var phoneNumber: String { get set }
    var detectedOperator: TelecomOperator { get }
    var isOperatorTagVisible: Bool { get }
    var standardTopUpAmounts: [Double] { get }
    var isPackagesSectionVisible: Bool { get }
    var availableCategories: [String] { get }
    var selectedCategory: String { get }
    var packGroupsForSelectedCategory: [(packName: String, packages: [PackageEntity])] { get }
    var validationError: String? { get }

    func onAppear() async
    func onPhoneNumberChanged(_ newNumber: String) async
    func selectCategory(_ category: String)
    func selectTopUpAmount(_ amount: Double, router: (any AppRouterProtocol)?)
    func selectPackage(_ package: PackageEntity, router: (any AppRouterProtocol)?)
    func clearValidationError()
    
}
