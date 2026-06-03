//
//  AppConfig.swift
//  AppTemplate
//
//  Created by Vijendran  on 6/02/26.
//

import Foundation

// MARK: - Environment

enum Environment {
    case development
    case demo
    case qa
    case production
}

// MARK: - App Configuration

struct AppConfig {
    /// Current active environment
    /// Change this to switch between environments
    static let current: Environment = .production

    /// Base URL for API endpoints
    static var baseURL: String {
        switch current {
        case .development:
            return "https://dummyjson.com"
        case .demo:
            return "https://dummyjson.com"
        case .qa:
            return "https://dummyjson.com"
        case .production:
            return "https://dummyjson.com"
        }
    }
}
