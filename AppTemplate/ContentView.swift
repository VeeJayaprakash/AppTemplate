//
//  ContentView.swift
//  AppTemplate
//
//  Created by Vijendran  on 5/19/26.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(DependencyContainer.self) var dependencyContainer:DependencyContainer
    
    var body: some View {
        VStack {
            if dependencyContainer.userSession.isUserLogged {
                    Button {
                        Task {
                            await dependencyContainer.userSession.clearTokens()
                        }
                    } label: {
                        Text("Log out")
                    }
                }else {
                    LoginView()
                }
        }
        .padding()
    }
}

#Preview {
    ContentView().environment(DependencyContainer.mockDependencyContainer)
}
