//
//  MainTabView.swift
//  AppTemplate
//
//  Created by Vijendran  on 6/1/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("Settings", systemImage: "gear") {
                SettingsView()
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
    return MainTabView()
        .environment(dependencies)
        .environment(factory)
}
