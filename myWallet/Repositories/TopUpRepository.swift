//
//  TopUpRepository.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData
import OSLog

@MainActor
public final class TopUpRepository: TopUpRepositoryProtocol {
    
    private let networkService: MockNetworkServiceProtocol
    private let modelContext: ModelContext
    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: Constants.Logging.repositoryCategory
    )

    public init(
        networkService: MockNetworkServiceProtocol,
        modelContext: ModelContext
    ) {
        self.networkService = networkService
        self.modelContext = modelContext
    }

    public func getPackages(for operatorName: String) async throws -> [PackageEntity] {
        do {
            // 1. Network First: Query remote endpoint for latest catalog
            let remoteDTOs = try await networkService.fetchPackages()

            // 2. Persist fresh data into SwiftData
            for dto in remoteDTOs {
                modelContext.insert(dto.toEntity())
            }
            try? modelContext.save()
            logger.info("Successfully refreshed packages from network for operator: \(operatorName, privacy: .public)")

            // 3. Query SwiftData single source of truth
            return try fetchCachedPackages(for: operatorName)
        } catch {
            // 4. Network Failure: Fallback to local SwiftData cache
            logger.warning("Network request failed. Attempting local cache fallback for operator: \(operatorName, privacy: .public)")
            let cached = try fetchCachedPackages(for: operatorName)

            if !cached.isEmpty {
                logger.info("Serving \(cached.count) cached packages offline for operator: \(operatorName, privacy: .public)")
                return cached
            } else {
                logger.error("No cached packages available and network failed for operator: \(operatorName, privacy: .public)")
                throw AppError.networkFailure
            }
        }
    }

    public func prefetchPackages() async {
        do {
            let dtos = try await networkService.fetchPackages()
            for dto in dtos {
                modelContext.insert(dto.toEntity())
            }
            try? modelContext.save()
            logger.info("Successfully pre-loaded packages in background.")
        } catch {
            logger.debug("Background pre-loading of packages completed with error (ignored): \(error.localizedDescription, privacy: .public)")
        }
    }

    public func saveTransaction(_ transaction: TransactionHistory) throws {
        modelContext.insert(transaction)
        try modelContext.save()
        logger.info("Saved transaction to SwiftData successfully.")
    }

    private func fetchCachedPackages(for operatorName: String) throws -> [PackageEntity] {
        let descriptor = FetchDescriptor<PackageEntity>(
            predicate: #Predicate<PackageEntity> { entity in
                entity.operatorName == operatorName
            },
            sortBy: [SortDescriptor(\.amount, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }
    
}
