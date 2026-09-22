//
//  TopUpRepository.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData
import OSLog

/// Concrete repository implementation using Network-First with Local Cache Fallback for package catalogs.
@MainActor
public final class TopUpRepository: TopUpRepositoryProtocol {
    
    private let networkService: MockNetworkServiceProtocol
    private let modelContext: ModelContext
    private var inMemoryCache: [String: [PackageEntity]] = [:]
    
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
            saveContext()
            logger.info("Successfully refreshed packages from network for operator: \(operatorName, privacy: .public)")

            // 3. Query SwiftData single source of truth
            let freshPackages = try fetchCachedPackages(for: operatorName)
            inMemoryCache[operatorName] = freshPackages
            return freshPackages
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            // 4. Network Failure: Fallback to in-memory or local SwiftData cache
            if let memoryCached = inMemoryCache[operatorName], !memoryCached.isEmpty {
                logger.info("Serving \(memoryCached.count) cached packages from memory for operator: \(operatorName, privacy: .public)")
                return memoryCached
            }

            logger.warning("Network request failed. Attempting local SwiftData cache fallback for operator: \(operatorName, privacy: .public)")
            let cached = try fetchCachedPackages(for: operatorName)

            if !cached.isEmpty {
                logger.info("Serving \(cached.count) cached packages offline for operator: \(operatorName, privacy: .public)")
                inMemoryCache[operatorName] = cached
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
            saveContext()
            logger.info("Successfully pre-loaded packages in background.")
        } catch is CancellationError {
            return
        } catch {
            logger.debug("Background pre-loading of packages completed with error (ignored): \(error.localizedDescription, privacy: .public)")
        }
    }

    public func saveTransaction(_ transaction: TransactionHistory) throws {
        modelContext.insert(transaction)
        do {
            try modelContext.save()
            logger.info("Saved transaction \(transaction.referenceNumber, privacy: .public) to SwiftData successfully.")
        } catch {
            logger.error("Failed to save transaction to SwiftData: \(error.localizedDescription, privacy: .public)")
            throw AppError.persistenceFailure(error.localizedDescription)
        }
    }

    // MARK: - Private Helpers
    private func fetchCachedPackages(for operatorName: String) throws -> [PackageEntity] {
        let descriptor = FetchDescriptor<PackageEntity>(
            predicate: #Predicate<PackageEntity> { entity in
                entity.operatorName == operatorName
            },
            sortBy: [SortDescriptor(\.amount, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save SwiftData context in TopUpRepository: \(error.localizedDescription, privacy: .public)")
        }
    }
    
}
