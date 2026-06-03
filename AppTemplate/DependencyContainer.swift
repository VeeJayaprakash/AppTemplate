//
//  DependencyContainer.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/19/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class DependencyContainer {
    // MARK: - Storage Layer

    let keychainManager: KeychainManagerProtocol

    // MARK: - Network Layer

    let networkClient: NetworkClientProtocol
    var userSession: UserSession
    let apiClient: APIClient

    // MARK: - API Services

    let loginAPIService: LoginAPIServiceProtocol
    let homeAPIService: HomeAPIServiceProtocol
    let settingsAPIService: SettingsAPIServiceProtocol

    // MARK: - Initialization

    init() {
        // Initialize Keychain Manager (secure storage)
        self.keychainManager = KeychainManager()

        // Initialize NetworkClient (base layer)
        self.networkClient = NetworkClient()

        // Initialize UserSession (token management with persistence)
        let userSession = UserSession(
            networkClient: networkClient,
            keychainManager: keychainManager
        )
        self.userSession = userSession

        // Initialize APIClient (authenticated wrapper)
        self.apiClient = APIClient(
            networkClient: networkClient,
            tokenProvider: userSession
        )

        // Initialize API Services
        self.loginAPIService = LoginAPIService(networkClient: networkClient)
        self.homeAPIService = HomeAPIService(networkClient: networkClient)
        self.settingsAPIService = SettingsAPIService(apiClient: apiClient)
    }

#if DEBUG
    static let mockDependencyContainer: DependencyContainer = {
        let container = DependencyContainer()
        // Use mock keychain for previews to avoid persisting test data
        return container
    }()

    // Alternative initializer for testing with mock dependencies
    init(keychainManager: KeychainManagerProtocol) {
        self.keychainManager = keychainManager
        self.networkClient = NetworkClient()

        let userSession = UserSession(
            networkClient: networkClient,
            keychainManager: keychainManager
        )
        self.userSession = userSession

        self.apiClient = APIClient(
            networkClient: networkClient,
            tokenProvider: userSession
        )

        self.loginAPIService = LoginAPIService(networkClient: networkClient)
        self.homeAPIService = HomeAPIService(networkClient: networkClient)
        self.settingsAPIService = SettingsAPIService(apiClient: apiClient)
    }
#endif
}

