//
//  AppTemplateApp.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/19/26.
//

import SwiftUI

@main
struct AppTemplateApp: App {
    let dependencies = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencies)
        }
    }
}
