//
//  SettingsAPIService.swift
//  AppTemplate
//
//  Created by Vijendran  on 6/02/26.
//

import Foundation

// MARK: - Endpoint

struct UserProfileEndpoint: Endpoint {
    var path: String {
        return "/auth/me"
    }

    var method: HTTPMethod {
        return .get
    }
}

// MARK: - API Service

protocol SettingsAPIServiceProtocol {
    func fetchUserProfile() async throws -> User
}

final class SettingsAPIService: SettingsAPIServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchUserProfile() async throws -> User {
        let endpoint = UserProfileEndpoint()
        // Reuses existing User model - extra fields in API response are ignored
        return try await apiClient.request(endpoint: endpoint)
    }
}
