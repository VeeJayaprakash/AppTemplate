//
//  SettingsViewModel.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/19/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var fetchedUser: User?
    var isLoadingProfile: Bool = false
    var profileError: String?

    private let settingsAPIService: SettingsAPIServiceProtocol

    init(settingsAPIService: SettingsAPIServiceProtocol) {
        self.settingsAPIService = settingsAPIService
    }

    // MARK: - Public Methods

    /// Fetches user profile using authenticated API call
    /// This tests the token refresh flow when token expires
    func loadUserProfile() async {
        guard !isLoadingProfile else { return }

        isLoadingProfile = true
        profileError = nil

        do {
            fetchedUser = try await settingsAPIService.fetchUserProfile()
            print("✅ Successfully fetched user profile via authenticated API")
            print("   User: \(fetchedUser?.firstName ?? "") \(fetchedUser?.lastName ?? "")")
        } catch NetworkError.httpError(let statusCode, _) where statusCode == 401 {
            profileError = "Unauthorized - Token may be invalid"
            print("❌ 401 Unauthorized - Token refresh should have triggered")
        } catch NetworkError.tokenRefreshFailed {
            profileError = "Token refresh failed"
            print("❌ Token refresh failed")
        } catch NetworkError.missingToken {
            profileError = "No access token available"
            print("❌ Missing token")
        } catch {
            profileError = error.localizedDescription
            print("❌ Error fetching profile: \(error)")
        }

        isLoadingProfile = false
    }
}
