//
//  LoginViewModel.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/22/26.
//

import Foundation
import Observation

// MARK: - Models

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let id: Int
    let email: String
    let firstName: String
    let lastName:String
    let accessToken: String
    let refreshToken: String
}

// MARK: - Endpoint

struct LoginEndpoint: Endpoint {
    var path: String {
        return "/auth/login"
    }

    var method: HTTPMethod {
        return .post
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class LoginViewModel {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let loginAPIService: LoginAPIServiceProtocol
    private let userSession: UserSession

    init(
        loginAPIService: LoginAPIServiceProtocol,
        userSession: UserSession
    ) {
        self.loginAPIService = loginAPIService
        self.userSession = userSession
    }

    func login() async {
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await loginAPIService.login(
                email: email,
                password: password
            )

            let user = User(id: response.id, email: response.email, firstName: response.firstName, lastName: response.lastName)
                        
            // Update UserSession with tokens and user
            userSession.setUserSession(
                user: user,
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )

            // Success - view will automatically update

        } catch NetworkError.httpError(let statusCode, _) where statusCode == 400 {
            errorMessage = "Invalid user id or password"
        } catch NetworkError.networkError {
            errorMessage = "Network error. Please check your connection."
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
