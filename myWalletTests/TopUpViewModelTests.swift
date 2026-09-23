//
//  TopUpViewModelTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 23/9/2569 BE.
//

import Testing
import Foundation
@testable import myWallet

@Suite("TopUpViewModel Tests")
@MainActor
struct TopUpViewModelTests {

    private func makeSUT(
        detectedPrefix: TelecomPrefixEntity? = nil,
        cachedPackages: [PackageEntity] = [],
        debounceNanoseconds: UInt64 = 0
    ) -> (TopUpViewModel, MockTelecomRepository, MockTopUpRepository, MockAppRouter) {
        let telecomRepo = MockTelecomRepository()
        telecomRepo.detectedPrefixToReturn = detectedPrefix

        let topUpRepo = MockTopUpRepository()
        topUpRepo.cachedPackagesToReturn = cachedPackages
        let router = MockAppRouter()

        let viewModel = TopUpViewModel(
            telecomRepository: telecomRepo,
            topUpRepository: topUpRepo,
            router: router,
            debounceNanoseconds: debounceNanoseconds
        )
        return (viewModel, telecomRepo, topUpRepo, router)
    }

    private func sampleMPTPackages() -> [PackageEntity] {
        [
            PackageEntity(
                id: "pkg_1",
                operatorName: "MPT",
                category: "Data",
                packGroup: "A Kyite Kyi",
                name: "Combo 1000MB (YouTube; TikTok; Telegram) (7 Days)",
                packageDescription: "Test",
                amount: 998,
                validityDays: 7,
                validityText: "7 Days",
                isPopular: false
            ),
            PackageEntity(
                id: "pkg_2",
                operatorName: "MPT",
                category: "Data",
                packGroup: "Data Carry Plus",
                name: "263MB (30 Days)",
                packageDescription: "Test",
                amount: 999,
                validityDays: 30,
                validityText: "30 Days",
                isPopular: true
            ),
            PackageEntity(
                id: "pkg_3",
                operatorName: "MPT",
                category: "Auto Renewal Package",
                packGroup: "Auto Data",
                name: "Auto 1GB (30 Days)",
                packageDescription: "Test",
                amount: 1299,
                validityDays: 30,
                validityText: "30 Days",
                isPopular: false
            )
        ]
    }

    @Test("Initial state has empty phone, invisible operator tag, and hidden packages")
    func initialState() {
        let (viewModel, _, _, _) = makeSUT()

        #expect(viewModel.phoneNumber.isEmpty)
        #expect(viewModel.detectedOperator == .unknown)
        #expect(viewModel.isOperatorTagVisible == false)
        #expect(viewModel.isPackagesSectionVisible == false)
        #expect(viewModel.standardTopUpAmounts.count == 10)
        #expect(viewModel.standardTopUpAmounts.first == 1000)
        #expect(viewModel.standardTopUpAmounts.last == 30000)
        #expect(viewModel.availableCategories.isEmpty)
    }

    @Test("Myanmar numerals are normalized to Arabic digits and prefix standardizes to 09")
    func phoneNormalization() async {
        let (viewModel, _, _, _) = makeSUT()

        // Myanmar numerals: ၀၉၂၅၀၀၀၀၀၀၀ -> 09250000000
        await viewModel.onPhoneNumberChanged("၀၉၂၅၀၀၀၀၀၀၀")
        #expect(viewModel.phoneNumber == "09250000000")

        // 959 prefix -> 09
        await viewModel.onPhoneNumberChanged("959250000000")
        #expect(viewModel.phoneNumber == "09250000000")
    }

    @Test("Less than 3 digits does not trigger operator detection")
    func lessThanThreeDigits() async {
        let (viewModel, _, _, _) = makeSUT()

        await viewModel.onPhoneNumberChanged("09")
        #expect(viewModel.detectedOperator == .unknown)
        #expect(viewModel.isOperatorTagVisible == false)
        #expect(viewModel.isPackagesSectionVisible == false)
    }

    @Test("Valid MPT prefix triggers operator detection, reveals tag, and organizes packages")
    func validOperatorDetection() async {
        let mptPrefix = TelecomPrefixEntity(
            prefix: "0925",
            operatorName: "MPT",
            brandDisplayName: "MPT",
            brandLogoName: "antenna.radiowaves.left.and.right"
        )
        let (viewModel, _, _, _) = makeSUT(
            detectedPrefix: mptPrefix,
            cachedPackages: sampleMPTPackages()
        )

        await viewModel.onPhoneNumberChanged("09253366392")

        #expect(viewModel.detectedOperator == .mpt)
        #expect(viewModel.isOperatorTagVisible == true)
        #expect(viewModel.isPackagesSectionVisible == true)
        #expect(viewModel.availableCategories == ["Data", "Auto Renewal Package"])
        #expect(viewModel.selectedCategory == "Data")

        // Check pack groups under Data
        let groups = viewModel.packGroupsForSelectedCategory
        #expect(groups.count == 2)
        #expect(groups[0].packName == "A Kyite Kyi")
        #expect(groups[0].packages.count == 1)
        #expect(groups[1].packName == "Data Carry Plus")
        #expect(groups[1].packages.count == 1)
        #expect(groups[1].packages[0].isPopular == true)
    }

    @Test("Switching category updates pack groups correctly")
    func categorySwitching() async {
        let mptPrefix = TelecomPrefixEntity(
            prefix: "0925",
            operatorName: "MPT",
            brandDisplayName: "MPT",
            brandLogoName: "antenna.radiowaves.left.and.right"
        )
        let (viewModel, _, _, _) = makeSUT(
            detectedPrefix: mptPrefix,
            cachedPackages: sampleMPTPackages()
        )

        await viewModel.onPhoneNumberChanged("09253366392")
        #expect(viewModel.selectedCategory == "Data")

        viewModel.selectCategory("Auto Renewal Package")
        #expect(viewModel.selectedCategory == "Auto Renewal Package")

        let groups = viewModel.packGroupsForSelectedCategory
        #expect(groups.count == 1)
        #expect(groups[0].packName == "Auto Data")
        #expect(groups[0].packages.count == 1)
    }

    @Test("Clearing phone number hides operator tag and packages section")
    func clearingPhoneNumber() async {
        let mptPrefix = TelecomPrefixEntity(
            prefix: "0925",
            operatorName: "MPT",
            brandDisplayName: "MPT",
            brandLogoName: "antenna.radiowaves.left.and.right"
        )
        let (viewModel, _, _, _) = makeSUT(
            detectedPrefix: mptPrefix,
            cachedPackages: sampleMPTPackages()
        )

        await viewModel.onPhoneNumberChanged("09253366392")
        #expect(viewModel.isOperatorTagVisible == true)
        #expect(viewModel.isPackagesSectionVisible == true)

        await viewModel.onPhoneNumberChanged("")
        #expect(viewModel.isOperatorTagVisible == false)
        #expect(viewModel.isPackagesSectionVisible == false)
        #expect(viewModel.detectedOperator == .unknown)
    }

    @Test("Selecting top-up amount with invalid phone fails validation without navigation")
    func selectAmountInvalidPhone() {
        let (viewModel, _, _, router) = makeSUT()

        viewModel.selectTopUpAmount(1000)
        #expect(viewModel.validationError != nil)
        #expect(router.navigatedRoutes.isEmpty)
    }

    @Test("Selecting top-up amount with valid phone navigates to TopUpDetail")
    func selectAmountValidPhone() async {
        let mptPrefix = TelecomPrefixEntity(
            prefix: "0925",
            operatorName: "MPT",
            brandDisplayName: "MPT",
            brandLogoName: "antenna.radiowaves.left.and.right"
        )
        let (viewModel, _, _, router) = makeSUT(
            detectedPrefix: mptPrefix,
            cachedPackages: sampleMPTPackages()
        )
        await viewModel.onPhoneNumberChanged("09253366392")
        viewModel.selectTopUpAmount(5000)

        #expect(viewModel.validationError == nil)
        #expect(router.navigatedRoutes.count == 1)

        guard case .topUpDetail(let params) = router.navigatedRoutes.first else {
            Issue.record("Expected .topUpDetail route")
            return
        }

        #expect(params.phone == "09253366392")
        #expect(params.operatorType == .mpt)
        #expect(params.amount == 5000)
    }

    @Test("Selecting package with valid phone navigates to TopUpDetail")
    func selectPackageValidPhone() async {
        let mptPrefix = TelecomPrefixEntity(
            prefix: "0925",
            operatorName: "MPT",
            brandDisplayName: "MPT",
            brandLogoName: "antenna.radiowaves.left.and.right"
        )
        let packages = sampleMPTPackages()
        let (viewModel, _, _, router) = makeSUT(
            detectedPrefix: mptPrefix,
            cachedPackages: packages
        )
        await viewModel.onPhoneNumberChanged("09253366392")
        viewModel.selectPackage(packages[0])

        #expect(viewModel.validationError == nil)
        #expect(router.navigatedRoutes.count == 1)

        guard case .topUpDetail(let params) = router.navigatedRoutes.first else {
            Issue.record("Expected .topUpDetail route")
            return
        }

        #expect(params.phone == "09253366392")
        #expect(params.operatorType == .mpt)
        #expect(params.planTitle == packages[0].name)
        #expect(params.amount == 998)
    }

    @Test("Debouncing and structured task cancellation: rapid successive keystrokes cancel earlier tasks")
    func debouncingAndTaskCancellation() async {
        let mptPrefix = TelecomPrefixEntity(
            prefix: "0925",
            operatorName: "MPT",
            brandDisplayName: "MPT",
            brandLogoName: "mpt"
        )
        let (viewModel, _, _, _) = makeSUT(
            detectedPrefix: mptPrefix,
            debounceNanoseconds: 50_000_000 // 50ms
        )

        // Fire initial keystroke
        let task1 = Task {
            await viewModel.onPhoneNumberChanged("092")
        }

        // Allow task1 to start execution on MainActor before firing the second keystroke
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Fire next keystroke before the 50ms debounce window of task1 expires
        let task2 = Task {
            await viewModel.onPhoneNumberChanged("09250000000")
        }

        _ = await task1.result
        _ = await task2.result

        #expect(viewModel.phoneNumber == "09250000000")
        #expect(viewModel.detectedOperator == .mpt)
    }

    @Test("Generic view protocol decoupling: mock view model conforms to TopUpViewModelProtocol without runtime cast")
    func genericViewModelProtocolDecoupling() async {
        let mockVM = MockTopUpViewModel()
        mockVM.phoneNumber = "09778239012"
        mockVM.detectedOperator = .atom
        mockVM.isOperatorTagVisible = true

        let _: TopUpMainView<MockTopUpViewModel> = TopUpMainView(viewModel: mockVM)
        #expect(mockVM.phoneNumber == "09778239012")
        #expect(mockVM.detectedOperator == .atom)
    }
    
}
