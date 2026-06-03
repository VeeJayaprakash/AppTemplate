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
    private let keychainManager: KeychainManagerProtocol

    // Track ongoing refresh to prevent duplicates
    private var ongoingRefreshTask: Task<Void, Error>?

    var currentUser: User?
    private(set) var isUserLogged: Bool = false

    // MARK: - Keychain Keys

    private enum KeychainKey {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let currentUser = "currentUser"
    }

    init(networkClient: NetworkClientProtocol, keychainManager: KeychainManagerProtocol) {
        self.networkClient = networkClient
        self.keychainManager = keychainManager

        // Attempt to restore session from keychain
        loadPersistedSession()
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

        // Clear from keychain
        try? keychainManager.deleteAll()
    }

    // MARK: - Token Management

    func setUserSession(user: User, accessToken: String, refreshToken: String) {
        self.currentUser = user
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isUserLogged = true

        // Persist to keychain
        persistSession()
    }

    func setTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        isUserLogged = true

        // Persist to keychain
        persistTokens()
    }

    private func updateTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken

        // Persist updated tokens to keychain
        persistTokens()
    }

    // MARK: - Keychain Persistence

    private func loadPersistedSession() {
        do {
            // Try to load tokens and user from keychain
            let accessToken = try keychainManager.retrieve(
                forKey: KeychainKey.accessToken,
                as: String.self
            )
            let refreshToken = try keychainManager.retrieve(
                forKey: KeychainKey.refreshToken,
                as: String.self
            )
            let user = try keychainManager.retrieve(
                forKey: KeychainKey.currentUser,
                as: User.self
            )

            // If all data is present, restore session
            if let accessToken, let refreshToken, let user {
                self.accessToken = accessToken
                self.refreshToken = refreshToken
                self.currentUser = user
                self.isUserLogged = true
            }
        } catch {
            // Session not found or corrupted, start fresh
            // Silent failure - this is expected for new installs or after logout
        }
    }

    private func persistSession() {
        do {
            try keychainManager.save(accessToken, forKey: KeychainKey.accessToken)
            try keychainManager.save(refreshToken, forKey: KeychainKey.refreshToken)
            if let currentUser {
                try keychainManager.save(currentUser, forKey: KeychainKey.currentUser)
            }
        } catch {
            // Log error in production - for now, silent failure
            print("Failed to persist session to keychain: \(error)")
        }
    }

    private func persistTokens() {
        do {
            try keychainManager.save(accessToken, forKey: KeychainKey.accessToken)
            try keychainManager.save(refreshToken, forKey: KeychainKey.refreshToken)
        } catch {
            // Log error in production - for now, silent failure
            print("Failed to persist tokens to keychain: \(error)")
        }
    }
}
