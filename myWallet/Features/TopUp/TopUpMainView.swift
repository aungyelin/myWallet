//
//  TopUpMainView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

@MainActor
struct TopUpMainView<VM: TopUpViewModelProtocol>: View {
    @Environment(\.appContainer) private var appContainer
    private let customViewModel: VM?

    init(viewModel: VM) {
        self.customViewModel = viewModel
    }

    var body: some View {
        if let customViewModel {
            TopUpContentView(viewModel: customViewModel)
        } else if let appContainer {
            TopUpContainerLoadedView(container: appContainer)
        } else {
            ProgressView()
        }
    }
}

extension TopUpMainView where VM == TopUpViewModel {
    @MainActor
    init() {
        self.customViewModel = nil
    }
}

@MainActor
private struct TopUpContainerLoadedView: View {
    @State private var viewModel: TopUpViewModel

    init(container: any AppContainerProtocol) {
        _viewModel = State(wrappedValue: TopUpViewModel(
            telecomRepository: container.telecomRepository,
            topUpRepository: container.topUpRepository
        ))
    }

    var body: some View {
        TopUpContentView(viewModel: viewModel)
    }
}

@MainActor
private struct TopUpContentView<VM: TopUpViewModelProtocol>: View {
    @Bindable var viewModel: VM
    @Environment(\.appRouter) private var router
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @FocusState private var isPhoneFocused: Bool

    private var topUpGridColumns: [GridItem] {
        if horizontalSizeClass == .regular {
            return [GridItem(.adaptive(minimum: 140, maximum: 180), spacing: LayoutMetrics.spacingMedium)]
        } else {
            return Array(repeating: GridItem(.flexible(), spacing: LayoutMetrics.spacingSmall), count: 3)
        }
    }

    private var packageGridColumns: [GridItem] {
        if horizontalSizeClass == .regular {
            return [GridItem(.adaptive(minimum: 240, maximum: 360), spacing: LayoutMetrics.spacingMedium)]
        } else {
            return Array(repeating: GridItem(.flexible(), spacing: LayoutMetrics.spacingSmall), count: 2)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LayoutMetrics.spacingLarge) {
                
                // Phone Number Input Section
                VStack(alignment: .leading, spacing: LayoutMetrics.spacingMedium) {
                    HStack {
                        Spacer()
                        
                        TelecomBadgeView(
                            operatorType: viewModel.detectedOperator,
                            style: .cardBadge
                        )
                        .opacity(viewModel.isOperatorTagVisible ? 1.0 : 0.0)
                    }
                    .frame(height: 24)

                    // Phone Number Field Card
                    HStack(spacing: LayoutMetrics.spacingSmall) {
                        TextField(
                            String(localized: "top_up_phone_placeholder"),
                            text: $viewModel.phoneNumber
                        )
                        .font(.title3)
                        .fontWeight(.semibold)
                        .keyboardType(.numberPad)
                        .focused($isPhoneFocused)
                        .onChange(of: viewModel.phoneNumber) { _, newValue in
                            Task {
                                await viewModel.onPhoneNumberChanged(newValue)
                            }
                        }

                        if !viewModel.phoneNumber.isEmpty {
                            Button(action: {
                                viewModel.phoneNumber = ""
                                Task {
                                    await viewModel.onPhoneNumberChanged("")
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(LayoutMetrics.spacingMedium)
                    .background(AppColors.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium))
                    .overlay(
                        RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadiusMedium)
                            .stroke(
                                viewModel.validationError != nil ? Color.red : AppColors.cardBorder,
                                lineWidth: 1
                            )
                    )

                    // Validation Error Text
                    if let error = viewModel.validationError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.top, LayoutMetrics.spacingMicro)
                    }
                }

                // Top-Up Amount Section
                VStack(alignment: .leading, spacing: LayoutMetrics.spacingMedium) {
                    Text(String(localized: "top_up_amount_section_title"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    LazyVGrid(columns: topUpGridColumns, spacing: LayoutMetrics.spacingSmall) {
                        ForEach(viewModel.standardTopUpAmounts, id: \.self) { amount in
                            TopUpAmountTileView(amount: amount) {
                                isPhoneFocused = false
                                viewModel.selectTopUpAmount(amount, router: router)
                            }
                        }
                    }
                }

                // Operator Packages Section (Displayed when operator is detected)
                if viewModel.isPackagesSectionVisible {
                    VStack(alignment: .leading, spacing: LayoutMetrics.spacingMedium) {
                        Text(String(localized: "top_up_packages_section_title"))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        // Horizontal Category Chips List
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: LayoutMetrics.spacingSmall) {
                                ForEach(viewModel.availableCategories, id: \.self) { category in
                                    categoryChip(for: category)
                                }
                            }
                        }
                        .padding(.bottom, LayoutMetrics.spacingMedium)

                        // Vertical List of Pack Groups
                        VStack(alignment: .leading, spacing: LayoutMetrics.spacingLarge) {
                            ForEach(viewModel.packGroupsForSelectedCategory, id: \.packName) { group in
                                VStack(alignment: .leading, spacing: LayoutMetrics.spacingSmall) {
                                    Text(group.packName)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.secondary)

                                    LazyVGrid(columns: packageGridColumns, spacing: LayoutMetrics.spacingSmall) {
                                        ForEach(group.packages, id: \.id) { package in
                                            PackageCardView(package: package) {
                                                isPhoneFocused = false
                                                viewModel.selectPackage(package, router: router)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer(minLength: LayoutMetrics.spacingExtraLarge)
            }
            .padding(.horizontal, LayoutMetrics.screenHorizontalPadding)
            .padding(.top, LayoutMetrics.spacingSmall)
            .frame(maxWidth: LayoutMetrics.maxContentWidth)
        }
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: .infinity)
        .background(AppColors.screenBackground)
        .navigationTitle(String(localized: "top_up_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(String(localized: "action_done")) {
                    isPhoneFocused = false
                }
            }
        }
        .onTapGesture {
            isPhoneFocused = false
        }
        .task {
            await viewModel.onAppear()
        }
    }

    @ViewBuilder
    private func categoryChip(for category: String) -> some View {
        let isSelected = viewModel.selectedCategory == category

        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.selectCategory(category)
            }
        }) {
            HStack(spacing: LayoutMetrics.spacingMicro) {
                Image(systemName: iconForCategory(category))
                    .font(.caption)
                Text(category)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .medium)
            }
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .padding(.horizontal, LayoutMetrics.spacingStandard)
            .padding(.vertical, LayoutMetrics.spacingSmall)
            .background(isSelected ? Color.accentColor : AppColors.cardSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : AppColors.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func iconForCategory(_ category: String) -> String {
        let lower = category.lowercased()
        if lower.contains("auto") {
            return "arrow.2.squarepath"
        } else if lower.contains("data") {
            return "wifi"
        } else if lower.contains("voice") {
            return "phone.fill"
        } else if lower.contains("entertainment") || lower.contains("stream") {
            return "play.tv.fill"
        } else if lower.contains("sms") {
            return "message.fill"
        } else if lower.contains("roaming") {
            return "globe"
        } else {
            return "sparkles"
        }
    }
}

#Preview("TopUpMainView - iPhone") {
    NavigationStack {
        TopUpMainView()
    }
}

#Preview("TopUpMainView - iPad", traits: .landscapeLeft) {
    NavigationStack {
        TopUpMainView()
    }
}
