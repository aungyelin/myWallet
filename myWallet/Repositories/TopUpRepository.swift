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
        let remoteDTOs: [PackageDTO]
        do {
            // 1. Network First: Query remote endpoint for latest catalog
            remoteDTOs = try await networkService.fetchPackages()
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            // Network failures may fall back to memory or SwiftData cache.
            if let memoryCached = inMemoryCache[operatorName], !memoryCached.isEmpty {
                logger.info("Serving cached packages from memory.")
                return memoryCached
            }

            logger.warning("Network request failed. Attempting local package cache fallback.")
            let cached = try fetchCachedPackages(for: operatorName)

            if !cached.isEmpty {
                logger.info("Serving cached packages offline.")
                inMemoryCache[operatorName] = cached
                return cached
            } else {
                logger.error("No cached packages available and network failed.")
                throw AppError.networkFailure
            }
        }

        // Persistence failures must not be treated as network failures.
        try replacePackageCatalog(with: remoteDTOs)
        logger.info("Successfully refreshed package catalog from network.")

        let freshPackages = try fetchCachedPackages(for: operatorName)
        inMemoryCache[operatorName] = freshPackages
        return freshPackages
    }

    public func prefetchPackages() async {
        do {
            let dtos = try await networkService.fetchPackages()
            try replacePackageCatalog(with: dtos)
            logger.info("Successfully pre-loaded packages in background.")
        } catch is CancellationError {
            return
        } catch {
            logger.debug("Background pre-loading of packages completed with error (ignored): \(error.localizedDescription, privacy: .public)")
        }
    }

    public func getCachedPackages(for operatorName: String) throws -> [PackageEntity] {
        if let memoryCached = inMemoryCache[operatorName], !memoryCached.isEmpty {
            return memoryCached
        }
        let cached = try fetchCachedPackages(for: operatorName)
        if !cached.isEmpty {
            inMemoryCache[operatorName] = cached
        }
        return cached
    }

    public func performRecharge(
        phone: String,
        operatorName: String,
        planTitle: String,
        amount: Double
    ) async throws -> TopUpRechargeResponseDTO {
        try await networkService.submitTopUpRecharge(
            phone: phone,
            operatorName: operatorName,
            planTitle: planTitle,
            amount: amount
        )
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

    private func replacePackageCatalog(with dtos: [PackageDTO]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<PackageEntity>())
        existing.forEach(modelContext.delete)
        dtos.forEach { modelContext.insert($0.toEntity()) }

        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save package catalog to SwiftData.")
            throw AppError.persistenceFailure(error.localizedDescription)
        }
    }
    
}
