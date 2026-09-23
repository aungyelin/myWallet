//
//  TopUpViewModel.swift
//  myWallet
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
public final class TopUpViewModel: TopUpViewModelProtocol {

    public var phoneNumber: String = ""
    public private(set) var detectedOperator: TelecomOperator = .unknown
    public private(set) var isOperatorTagVisible: Bool = false
    public let standardTopUpAmounts: [Double] = [1000, 2000, 3000, 4000, 5000, 10000, 15000, 20000, 25000, 30000]
    public private(set) var isPackagesSectionVisible: Bool = false
    public private(set) var availableCategories: [String] = []
    public private(set) var selectedCategory: String = ""
    public private(set) var validationError: String? = nil

    private var allPackagesForCurrentOperator: [PackageEntity] = []
    private let telecomRepository: TelecomRepositoryProtocol
    private let topUpRepository: TopUpRepositoryProtocol
    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: "TopUpViewModel"
    )

    private let debounceNanoseconds: UInt64
    private var debounceTask: Task<Void, Never>?

    public init(
        telecomRepository: TelecomRepositoryProtocol,
        topUpRepository: TopUpRepositoryProtocol,
        initialPhone: String = "",
        debounceNanoseconds: UInt64 = 150_000_000
    ) {
        self.telecomRepository = telecomRepository
        self.topUpRepository = topUpRepository
        self.phoneNumber = initialPhone
        self.debounceNanoseconds = debounceNanoseconds
    }

    public var packGroupsForSelectedCategory: [(packName: String, packages: [PackageEntity])] {
        let matchingPackages = allPackagesForCurrentOperator.filter { $0.category == selectedCategory }
        
        // Group preserving order of appearance
        var groups: [String: [PackageEntity]] = [:]
        var groupOrder: [String] = []

        for pkg in matchingPackages {
            let groupName = pkg.packGroup.isEmpty ? pkg.category : pkg.packGroup
            if groups[groupName] == nil {
                groups[groupName] = []
                groupOrder.append(groupName)
            }
            groups[groupName]?.append(pkg)
        }

        return groupOrder.compactMap { name in
            guard let pkgs = groups[name] else { return nil }
            return (packName: name, packages: pkgs)
        }
    }

    public func onAppear() async {
        // Pre-fetch prefix and package catalogs in background if needed
        async let prefetchPrefixes: () = telecomRepository.prefetchPrefixes()
        async let prefetchPackages: () = topUpRepository.prefetchPackages()
        _ = await (prefetchPrefixes, prefetchPackages)

        if !phoneNumber.isEmpty {
            await onPhoneNumberChanged(phoneNumber)
        }
    }

    public func onPhoneNumberChanged(_ newNumber: String) async {
        // Cancel any pending debounced detection task
        debounceTask?.cancel()

        let normalized = telecomRepository.sanitizeAndNormalize(newNumber)
        self.phoneNumber = normalized
        clearValidationError()

        guard !normalized.isEmpty else {
            resetOperatorAndPackages()
            return
        }

        guard normalized.count >= Constants.Telecom.minPrefixDetectionDigits else {
            resetOperatorAndPackages()
            return
        }

        // Debounce input to cancel rapid successive keystrokes and avoid race conditions
        let task = Task { [weak self] in
            if let debounce = self?.debounceNanoseconds, debounce > 0 {
                try? await Task.sleep(nanoseconds: debounce)
            }
            guard !Task.isCancelled, let self else { return }
            await self.performOperatorDetection(for: normalized)
        }
        self.debounceTask = task
        await task.value
    }

    private func performOperatorDetection(for normalized: String) async {
        guard !Task.isCancelled else { return }

        // Keystroke operator detection evaluates strictly offline (0ms)
        do {
            if let prefixEntity = try await telecomRepository.detectOperator(for: normalized) {
                guard !Task.isCancelled else { return }
                let op = prefixEntity.operatorType
                if op != detectedOperator {
                    self.detectedOperator = op
                    self.isOperatorTagVisible = true
                    await loadPackagesForOperator(op)
                }
            } else {
                guard !Task.isCancelled else { return }
                resetOperatorAndPackages()
            }
        } catch {
            guard !Task.isCancelled else { return }
            logger.error("Operator detection failed: \(error.localizedDescription, privacy: .public)")
            resetOperatorAndPackages()
        }
    }

    public func selectCategory(_ category: String) {
        self.selectedCategory = category
    }

    public func selectTopUpAmount(_ amount: Double, router: (any AppRouterProtocol)?) {
        guard validateInput() else { return }

        let params = TopUpCheckoutParams(
            phone: phoneNumber,
            operatorType: detectedOperator,
            planTitle: "\(CurrencyFormatter.format(amount)) \(String(localized: "top_up_title"))",
            amount: amount,
            fee: 0.0
        )
        router?.navigate(to: .topUpDetail(params))
    }

    public func selectPackage(_ package: PackageEntity, router: (any AppRouterProtocol)?) {
        guard validateInput() else { return }

        let params = TopUpCheckoutParams(
            phone: phoneNumber,
            operatorType: detectedOperator,
            planTitle: package.name,
            amount: package.amount,
            fee: 0.0
        )
        router?.navigate(to: .topUpDetail(params))
    }

    public func clearValidationError() {
        self.validationError = nil
    }

    // MARK: - Private Helpers
    private func resetOperatorAndPackages() {
        self.detectedOperator = .unknown
        self.isOperatorTagVisible = false
        self.isPackagesSectionVisible = false
        self.allPackagesForCurrentOperator = []
        self.availableCategories = []
        self.selectedCategory = ""
    }

    private func loadPackagesForOperator(_ operatorType: TelecomOperator) async {
        // Query local SwiftData database first (offline 0ms)
        var packages = (try? topUpRepository.getCachedPackages(for: operatorType.rawValue)) ?? []

        if packages.isEmpty {
            // Fallback to repository network-first/cache method
            packages = (try? await topUpRepository.getPackages(for: operatorType.rawValue)) ?? []
        }

        self.allPackagesForCurrentOperator = packages

        // Dynamically extract distinct categories for this operator
        var distinctCategories: [String] = []
        for pkg in packages {
            if !distinctCategories.contains(pkg.category) {
                distinctCategories.append(pkg.category)
            }
        }

        self.availableCategories = distinctCategories
        self.selectedCategory = distinctCategories.first ?? ""
        self.isPackagesSectionVisible = !packages.isEmpty
    }

    private func validateInput() -> Bool {
        let isMPT = detectedOperator == .mpt
        let hasValidLength = isMPT
            ? (Constants.Telecom.mptMinimumPhoneDigits...Constants.Telecom.mptMaximumPhoneDigits).contains(phoneNumber.count)
            : phoneNumber.count == Constants.Telecom.standardMobilePhoneDigits

        if phoneNumber.isEmpty || !phoneNumber.hasPrefix(Constants.Telecom.localPrefix) || !hasValidLength {
            self.validationError = String(localized: "top_up_error_enter_valid_phone")
            return false
        }
        if detectedOperator == .unknown {
            self.validationError = String(localized: "top_up_error_enter_valid_phone")
            return false
        }
        self.validationError = nil
        return true
    }
    
}
