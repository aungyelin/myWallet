//
//  TelecomRepository.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData
import OSLog

@MainActor
public final class TelecomRepository: TelecomRepositoryProtocol {
    
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

    public func getPrefixes() async throws -> [TelecomPrefixEntity] {
        do {
            // 1. Network First: Try fetching latest telecom prefixes from server
            let remoteDTOs = try await networkService.fetchTelecomPrefixes()

            // 2. Persist fresh data into SwiftData
            for dto in remoteDTOs {
                modelContext.insert(dto.toEntity())
            }
            try? modelContext.save()
            logger.info("Successfully refreshed telecom prefixes from network.")

            return try fetchCachedPrefixes()
        } catch {
            // 3. Network Failure: Fallback to SwiftData cache
            logger.warning("Network call failed while fetching prefixes. Falling back to local cache.")
            let cached = try fetchCachedPrefixes()

            if !cached.isEmpty {
                logger.info("Serving \(cached.count) cached prefixes offline.")
                return cached
            } else {
                logger.error("No cached prefixes available and network failed.")
                throw AppError.networkFailure
            }
        }
    }

    public func prefetchPrefixes() async {
        do {
            let dtos = try await networkService.fetchTelecomPrefixes()
            for dto in dtos {
                modelContext.insert(dto.toEntity())
            }
            try? modelContext.save()
            logger.info("Successfully pre-loaded telecom prefixes in background.")
        } catch {
            logger.debug("Background pre-loading of telecom prefixes completed with error (ignored): \(error.localizedDescription, privacy: .public)")
        }
    }

    public func detectOperator(for rawPhoneNumber: String) async throws -> TelecomPrefixEntity? {
        let normalized = sanitizeAndNormalize(rawPhoneNumber)

        guard normalized.count >= Constants.Telecom.minPrefixDetectionDigits else {
            return nil
        }

        let prefixes = try await getPrefixes()
        let sortedPrefixes = prefixes.sorted { $0.prefix.count > $1.prefix.count }

        for item in sortedPrefixes {
            if normalized.hasPrefix(item.prefix) {
                return item
            }
        }

        return nil
    }

    /// Sanitizes raw input and normalizes Myanmar mobile numbers to internal "09..." format.
    public func sanitizeAndNormalize(_ input: String) -> String {
        // Remove spaces, hyphens, parentheses, and non-numeric characters (except leading +)
        let cleaned = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        if cleaned.hasPrefix("+959") {
            return "09" + cleaned.dropFirst(4)
        } else if cleaned.hasPrefix("959") {
            return "09" + cleaned.dropFirst(3)
        } else if cleaned.hasPrefix("9") && cleaned.count >= 8 {
            return "0" + cleaned
        }

        return cleaned
    }

    private func fetchCachedPrefixes() throws -> [TelecomPrefixEntity] {
        let descriptor = FetchDescriptor<TelecomPrefixEntity>(
            sortBy: [SortDescriptor(\.prefix, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }
    
}
