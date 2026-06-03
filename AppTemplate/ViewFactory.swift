//
//  ViewFactory.swift
//  AppTemplate
//
//  Created by Vijendran  on 6/01/26.
//

import SwiftUI

@MainActor
@Observable
final class ViewFactory {
    private let dependencies: DependencyContainer

    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }

    // MARK: - Authentication Feature

    func makeLoginView() -> LoginView {
        let viewModel = LoginViewModel(
            loginAPIService: dependencies.loginAPIService,
            userSession: dependencies.userSession
        )
        return LoginView(viewModel: viewModel)
    }

    // MARK: - Home Feature

    func makeHomeView() -> HomeView {
        let viewModel = HomeViewModel(
            homeAPIService: dependencies.homeAPIService
        )
        return HomeView(viewModel: viewModel)
    }

    // MARK: - Settings Feature

    func makeSettingsView() -> SettingsView {
        let viewModel = SettingsViewModel(
            settingsAPIService: dependencies.settingsAPIService
        )
        return SettingsView(viewModel: viewModel)
    }

    // MARK: - Main Tab View

    func makeMainTabView() -> MainTabView {
        return MainTabView()
    }
}
