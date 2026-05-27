//
//  TokenProvider.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/22/26.
//

import Foundation

protocol TokenProvider: Sendable {
    /// Get current access token
    func getAccessToken() async throws -> String

    /// Force refresh the access token using refresh token
    func refreshToken() async throws

    /// Clear all tokens (logout)
    func clearTokens() async

    /// Check if user is authenticated
    var isAuthenticated: Bool { get async }
}
