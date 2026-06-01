//
//  SettingsView.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/19/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(DependencyContainer.self) private var dependencyContainer
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            List {
                if let user = dependencyContainer.userSession.currentUser {
                    Section {
                        LabeledContent("First Name", value: user.firstName)
                        LabeledContent("Last Name", value: user.lastName)
                        LabeledContent("Email", value: user.email)
                    }
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
    // Set a mock user for preview
    dependencies.userSession.setUserSession(
        user: User(id: 1, email: "test@example.com", firstName: "John", lastName: "Doe"),
        accessToken: "mock_token",
        refreshToken: "mock_refresh"
    )
    return SettingsView()
        .environment(dependencies)
}
