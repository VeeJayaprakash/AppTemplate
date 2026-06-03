//
//  SettingsView.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/19/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(DependencyContainer.self) private var dependencyContainer
    @State private var viewModel: SettingsViewModel
    @State private var showLogoutAlert = false

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                if let user = dependencyContainer.userSession.currentUser {
                    Section("User Information") {
                        LabeledContent("First Name", value: user.firstName)
                        LabeledContent("Last Name", value: user.lastName)
                        LabeledContent("Email", value: user.email)
                    }
                }

                // API Test Section - Tests authenticated endpoint and token refresh
                Section {
                    HStack {
                        Text("API Test Status")
                        Spacer()
                        if viewModel.isLoadingProfile {
                            ProgressView()
                        } else if let error = viewModel.profileError {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        } else if viewModel.fetchedUser != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.gray)
                        }
                    }

                    if let error = viewModel.profileError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Token Refresh Test")
                } footer: {
                    Text("This section tests the authenticated API call and token refresh flow. The API is called when you navigate to this screen.")
                        .font(.caption)
                }

                Section {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Logout")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                // Test authenticated API call whenever view appears
                // This will trigger token refresh if token is expired
                await viewModel.loadUserProfile()
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    Task {
                        await dependencyContainer.userSession.clearTokens()
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

#Preview {
    let dependencies = DependencyContainer.mockDependencyContainer
    let factory = ViewFactory(dependencies: dependencies)
    // Set a mock user for preview
    dependencies.userSession.setUserSession(
        user: User(id: 1, email: "test@example.com", firstName: "John", lastName: "Doe"),
        accessToken: "mock_token",
        refreshToken: "mock_refresh"
    )
    return factory.makeSettingsView()
        .environment(dependencies)
        .environment(factory)
}
