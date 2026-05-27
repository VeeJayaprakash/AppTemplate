//
//  APIClient.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/22/26.
//

import Foundation

final class APIClient: @unchecked Sendable {
    private let networkClient: NetworkClientProtocol
    private let tokenProvider: TokenProvider
    private let maxRetries: Int

    init(
        networkClient: NetworkClientProtocol,
        tokenProvider: TokenProvider,
        maxRetries: Int = 1
    ) {
        self.networkClient = networkClient
        self.tokenProvider = tokenProvider
        self.maxRetries = maxRetries
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        body: Encodable? = nil
    ) async throws -> T {
        return try await performAuthenticatedRequest(
            endpoint: endpoint,
            body: body,
            attempt: 0
        )
    }

    // MARK: - Private Methods

    private func performAuthenticatedRequest<T: Decodable>(
        endpoint: Endpoint,
        body: Encodable?,
        attempt: Int
    ) async throws -> T {
        do {
            // Get access token and inject into headers
            let authenticatedEndpoint = try await createAuthenticatedEndpoint(endpoint)

            // Perform request using NetworkClient
            return try await networkClient.request(
                endpoint: authenticatedEndpoint,
                body: body
            )
        } catch NetworkError.unauthorized {
            // Handle 401 - refresh token and retry
            return try await handleUnauthorized(
                endpoint: endpoint,
                body: body,
                attempt: attempt
            )
        }
    }

    private func createAuthenticatedEndpoint(
        _ endpoint: Endpoint
    ) async throws -> Endpoint {
        let token = try await tokenProvider.getAccessToken()
        return AuthenticatedEndpoint(
            baseEndpoint: endpoint,
            accessToken: token
        )
    }

    private func handleUnauthorized<T: Decodable>(
        endpoint: Endpoint,
        body: Encodable?,
        attempt: Int
    ) async throws -> T {
        guard attempt < maxRetries else {
            throw NetworkError.unauthorized
        }

        // Refresh token
        try await tokenProvider.refreshToken()

        // Retry request
        return try await performAuthenticatedRequest(
            endpoint: endpoint,
            body: body,
            attempt: attempt + 1
        )
    }
}

// MARK: - AuthenticatedEndpoint

private struct AuthenticatedEndpoint: Endpoint {
    let baseEndpoint: Endpoint
    let accessToken: String

    var baseURL: String { baseEndpoint.baseURL }
    var path: String { baseEndpoint.path }
    var method: HTTPMethod { baseEndpoint.method }
    var queryParameters: [String: String]? { baseEndpoint.queryParameters }

    var headers: [String: String]? {
        var headers = baseEndpoint.headers ?? [:]
        headers["Authorization"] = "Bearer \(accessToken)"
        return headers
    }
}
