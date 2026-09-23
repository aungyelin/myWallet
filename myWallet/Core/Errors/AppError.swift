//
//  AppError.swift
//  myWallet
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import Foundation

/// Strongly-typed domain errors with localized descriptions and recovery suggestions.
public enum AppError: LocalizedError, Equatable, Sendable {
    case invalidPhoneNumber
    case unrecognizedOperator
    case packageNotFound
    case networkFailure
    case decodingFailure(String)
    case persistenceFailure(String)
    case fileNotFound(String)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .invalidPhoneNumber:
            return AppLocalization.string("error_invalid_phone_number", defaultValue: "Please enter a valid Myanmar mobile number.")
        case .unrecognizedOperator:
            return AppLocalization.string("error_unrecognized_operator", defaultValue: "Unrecognized telecom operator for this phone number.")
        case .packageNotFound:
            return AppLocalization.string("error_package_not_found", defaultValue: "The selected package or denomination could not be found.")
        case .networkFailure:
            return AppLocalization.string("error_network_failure", defaultValue: "Network connection error. Please try again.")
        case .decodingFailure(let details):
            return AppLocalization.string("error_decoding_failure", defaultValue: "Failed to decode data: \(details)")
        case .persistenceFailure(let details):
            return AppLocalization.string("error_persistence_failure", defaultValue: "Failed to save data locally: \(details)")
        case .fileNotFound(let filename):
            return AppLocalization.string("error_file_not_found", defaultValue: "Resource file not found: \(filename)")
        case .unknown(let details):
            return AppLocalization.string("error_unknown", defaultValue: "An unexpected error occurred: \(details)")
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidPhoneNumber:
            return AppLocalization.string("recovery_invalid_phone_number", defaultValue: "Ensure the number starts with 09 and is 9 to 11 digits long.")
        case .unrecognizedOperator:
            return AppLocalization.string("recovery_unrecognized_operator", defaultValue: "Check the operator prefix or try another number.")
        case .packageNotFound:
            return AppLocalization.string("recovery_package_not_found", defaultValue: "Select an available package from the list.")
        case .networkFailure:
            return AppLocalization.string("recovery_network_failure", defaultValue: "Please verify your internet connection and retry.")
        case .decodingFailure, .persistenceFailure, .fileNotFound, .unknown:
            return AppLocalization.string("recovery_generic", defaultValue: "Please restart the application or contact support if the issue persists.")
        }
    }
}
