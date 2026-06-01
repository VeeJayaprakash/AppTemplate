//
//  ContentView.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/19/26.
//

import SwiftUI

struct ContentView: View {

    @Environment(DependencyContainer.self) var dependencyContainer: DependencyContainer
    @Environment(ViewFactory.self) var viewFactory: ViewFactory

    var body: some View {
        if dependencyContainer.userSession.isUserLogged {
            viewFactory.makeMainTabView()
        } else {
            viewFactory.makeLoginView()
        }
    }
}

#Preview {
    let dependencies = DependencyContainer.mockDependencyContainer
    let factory = ViewFactory(dependencies: dependencies)
    return ContentView()
        .environment(dependencies)
        .environment(factory)
}
