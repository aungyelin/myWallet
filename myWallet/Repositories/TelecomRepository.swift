//
//  TelecomRepository.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import SwiftData
import OSLog

/// Concrete repository implementation for telecom prefix detection using Network-First with Local Cache Fallback.
@MainActor
public final class TelecomRepository: TelecomRepositoryProtocol {
    
    private let networkService: MockNetworkServiceProtocol
    private let modelContext: ModelContext
    private var cachedPrefixes: [TelecomPrefixEntity] = []
    
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
            saveContext()
            logger.info("Successfully refreshed telecom prefixes from network.")

            let freshCached = try fetchCachedPrefixes()
            self.cachedPrefixes = freshCached
            return freshCached
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            // 3. Network Failure: Fallback to SwiftData cache
            logger.warning("Network call failed while fetching prefixes. Falling back to local cache.")
            let cached = try fetchCachedPrefixes()

            if !cached.isEmpty {
                logger.info("Serving \(cached.count) cached prefixes offline.")
                self.cachedPrefixes = cached
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
            saveContext()
            self.cachedPrefixes = (try? fetchCachedPrefixes()) ?? []
            logger.info("Successfully pre-loaded telecom prefixes in background.")
        } catch is CancellationError {
            return
        } catch {
            logger.debug("Background pre-loading of telecom prefixes completed with error (ignored): \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Evaluates mobile numbering prefixes strictly offline (0ms) against local caches as the user types.
    public func detectOperator(for rawPhoneNumber: String) async throws -> TelecomPrefixEntity? {
        let normalized = sanitizeAndNormalize(rawPhoneNumber)

        guard normalized.count >= Constants.Telecom.minPrefixDetectionDigits else {
            return nil
        }

        // 1. Prefer in-memory cache for 0ms keystroke lookup
        var prefixes = cachedPrefixes

        // 2. If memory cache is empty, check SwiftData local store without network delay
        if prefixes.isEmpty {
            prefixes = try fetchCachedPrefixes()
            self.cachedPrefixes = prefixes
        }

        // 3. If local cache is completely empty, fall back to initial sync
        if prefixes.isEmpty {
            prefixes = try await getPrefixes()
        }

        let sortedPrefixes = prefixes.sorted { $0.prefix.count > $1.prefix.count }

        for item in sortedPrefixes {
            if normalized.hasPrefix(item.prefix) {
                return item
            }
        }

        return nil
    }

    /// Sanitizes raw input, converts Myanmar numerals (၀-၉) to Arabic (0-9), and normalizes to standard "09..." format.
    public func sanitizeAndNormalize(_ input: String) -> String {
        guard !input.isEmpty else { return "" }

        // 1. Convert Myanmar Unicode numerals (U+1040 - U+1049) to Arabic digits ('0' - '9')
        var convertedString = ""
        let myanmarZeroScalar: UInt32 = 0x1040
        for char in input {
            if let scalar = char.unicodeScalars.first, scalar.value >= 0x1040 && scalar.value <= 0x1049 {
                let arabicDigit = scalar.value - myanmarZeroScalar
                convertedString.append(String(arabicDigit))
            } else {
                convertedString.append(char)
            }
        }

        // 2. Strip whitespace and symbols, retaining digits and leading '+'
        let trimmed = convertedString.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasLeadingPlus = trimmed.hasPrefix("+")
        let digitsOnly = trimmed.filter { $0.isNumber }
        let cleaned = hasLeadingPlus ? "+" + digitsOnly : digitsOnly

        // 3. Normalize international and local Myanmar prefixes to internal "09..."
        var standardized: String
        if cleaned.hasPrefix("+959") {
            standardized = "09" + cleaned.dropFirst(4)
        } else if cleaned.hasPrefix("959") {
            standardized = "09" + cleaned.dropFirst(3)
        } else if cleaned.hasPrefix("9") && cleaned.count >= 8 {
            standardized = "0" + cleaned
        } else {
            standardized = digitsOnly
        }

        // 4. Cap at Myanmar maximum mobile number length (11 digits)
        if standardized.count > 11 {
            return String(standardized.prefix(11))
        }

        return standardized
    }

    // MARK: - Private Helpers
    private func fetchCachedPrefixes() throws -> [TelecomPrefixEntity] {
        let descriptor = FetchDescriptor<TelecomPrefixEntity>(
            sortBy: [SortDescriptor(\.prefix, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save SwiftData context in TelecomRepository: \(error.localizedDescription, privacy: .public)")
        }
    }
    
}
