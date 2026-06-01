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
    // MARK: - Network Layer

    let networkClient: NetworkClientProtocol
    var userSession: UserSession
    let apiClient: APIClient

    // MARK: - API Services

    let loginAPIService: LoginAPIServiceProtocol

    // MARK: - Initialization

    init() {
        // Initialize NetworkClient (base layer)
        self.networkClient = NetworkClient()

        // Initialize UserSession (token management)
        let userSession = UserSession(networkClient: networkClient)
        self.userSession = userSession

        // Initialize APIClient (authenticated wrapper)
        self.apiClient = APIClient(
            networkClient: networkClient,
            tokenProvider: userSession
        )

        // Initialize API Services
        self.loginAPIService = LoginAPIService(networkClient: networkClient)
    }
    
#if DEBUG
    static let mockDependencyContainer = DependencyContainer()
#endif
}

