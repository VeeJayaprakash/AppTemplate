//
//  NetworkError.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/22/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case httpError(statusCode: Int, data: Data?)
    case unauthorized
    case networkError(Error)
    case tokenRefreshFailed
    case missingToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .httpError(let statusCode, _):
            return "HTTP error with status code: \(statusCode)"
        case .unauthorized:
            return "Unauthorized - authentication required"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .tokenRefreshFailed:
            return "Failed to refresh authentication token"
        case .missingToken:
            return "Authentication token is missing"
        }
    }
}
