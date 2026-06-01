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
    let viewFactory: ViewFactory

    init() {
        viewFactory = ViewFactory(dependencies: dependencies)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencies)
                .environment(viewFactory)
        }
    }
}
