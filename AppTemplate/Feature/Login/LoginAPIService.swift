//
//  LoginAPIService.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/22/26.
//

import Foundation

protocol LoginAPIServiceProtocol: Sendable {
    func login(email: String, password: String) async throws -> LoginResponse
}

final class LoginAPIService: LoginAPIServiceProtocol, @unchecked Sendable {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(username: email, password: password)

        // Use NetworkClient directly (no auth needed for login)
        let response: LoginResponse = try await networkClient.request(
            endpoint: LoginEndpoint(),
            body: request
        )

        return response
    }
}
