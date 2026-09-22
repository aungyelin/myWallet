//
//  MockNetworkService.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation
import OSLog

/// Concrete network simulation client that loads bundled JSON endpoints with artificial latency.
public final class MockNetworkService: MockNetworkServiceProtocol {
    
    private let bundle: Bundle
    private let latencyNanoseconds: UInt64
    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: Constants.Logging.networkCategory
    )

    public init(
        bundle: Bundle = Bundle(for: MockNetworkService.self),
        latencyNanoseconds: UInt64 = Constants.Network.defaultLatencyNanoseconds
    ) {
        self.bundle = bundle
        self.latencyNanoseconds = latencyNanoseconds
    }

    public func fetchTelecomPrefixes() async throws -> [TelecomPrefixDTO] {
        try await loadAndDecode(
            filename: Constants.ResourceFiles.telecomPrefixes,
            as: [TelecomPrefixDTO].self
        )
    }

    public func fetchPackages() async throws -> [PackageDTO] {
        try await loadAndDecode(
            filename: Constants.ResourceFiles.packages,
            as: [PackageDTO].self
        )
    }

    public func fetchSeedTransactions() async throws -> [TransactionHistoryDTO] {
        try await loadAndDecode(
            filename: Constants.ResourceFiles.sampleTransactions,
            as: [TransactionHistoryDTO].self
        )
    }

    private func loadAndDecode<T: Decodable>(
        filename: String,
        as type: T.Type
    ) async throws -> T {
        if latencyNanoseconds > 0 {
            try await Task.sleep(nanoseconds: latencyNanoseconds)
        }

        guard let url = bundle.url(
            forResource: filename,
            withExtension: Constants.ResourceFiles.jsonExtension
        ) else {
            logger.error("Missing bundled resource file: \(filename, privacy: .public).json")
            throw AppError.fileNotFound("\(filename).\(Constants.ResourceFiles.jsonExtension)")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(T.self, from: data)
            logger.info("Successfully fetched and decoded \(filename, privacy: .public).json")
            return result
        } catch let error as DecodingError {
            logger.error("Decoding failure for \(filename, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw AppError.decodingFailure(error.localizedDescription)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            logger.error("Error loading \(filename, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw AppError.networkFailure
        }
    }
    
}
