//
//  UserSession.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/22/26.
//

import Foundation
import Observation

@Observable
class UserSession: TokenProvider  {
    private var accessToken: String?
    private var refreshToken: String?

    private let networkClient: NetworkClientProtocol

    // Track ongoing refresh to prevent duplicates
    private var ongoingRefreshTask: Task<Void, Error>?

    var currentUser: User?
    private(set) var isUserLogged: Bool = false

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    // MARK: - TokenProvider Protocol
    var isAuthenticated: Bool {
        return accessToken != nil && refreshToken != nil
    }

    func getAccessToken() async throws -> String {
        guard let token = accessToken else {
            throw NetworkError.missingToken
        }
        return token
    }

    func refreshToken() async throws {
        // If refresh is already in progress, wait for it
        if let existingTask = ongoingRefreshTask {
            return try await existingTask.value
        }

        // Create new refresh task
        let refreshTask = Task<Void, Error> {
            // TODO: Replace with actual refresh endpoint and models
            // Example:
            // let endpoint = UserEndpoint.refreshToken
            // let requestBody = RefreshTokenRequest(refreshToken: currentRefreshToken)
            // let response: TokenResponse = try await networkClient.request(
            //     endpoint: endpoint,
            //     body: requestBody
            // )
            // await updateTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)

            throw NetworkError.tokenRefreshFailed
        }

        ongoingRefreshTask = refreshTask

        do {
            try await refreshTask.value
            ongoingRefreshTask = nil
        } catch {
            ongoingRefreshTask = nil
            throw error
        }
    }

    func clearTokens() async {
        accessToken = nil
        refreshToken = nil
        currentUser = nil
        isUserLogged = false
        ongoingRefreshTask?.cancel()
        ongoingRefreshTask = nil
    }

    // MARK: - Token Management

    func setUserSession(user: User, accessToken: String, refreshToken: String) {
        self.currentUser = user
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isUserLogged = true
    }

    func setTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        isUserLogged = true
    }

    private func updateTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
