//
//  LoginView.swift
//  TestLearning
//
//  Created by Vijendran  on 5/9/26.
//

import SwiftUI

struct LoginView: View {
    enum Fields: Hashable { case email, password }
    
    @Environment(DependencyContainer.self) var dependencyContainer
    @FocusState private var focusField: Fields?
    @State private var email:String = ""
    @State private var password:String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sign in")
                .font(.largeTitle.bold())
                .padding(.bottom, 10)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .foregroundStyle(.black)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .submitLabel(.next)
                .focused($focusField, equals: .email)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .foregroundStyle(.black)
                .textContentType(.password)
                .submitLabel(.done)
                .focused($focusField, equals: .password)
            
            Button {
                focusField = nil
                // dependencyContainer.userSession.loginUser()
            } label: {
                Text("Login")
                    .padding()
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
            Spacer()
        }
        .padding()
        .onSubmit {
            switch focusField {
            case .email: focusField = .password
            case .password: focusField = nil
            case .none: break
            }
        }
        .onAppear { focusField = .email }
    }
}

#Preview {
    LoginView().environment(DependencyContainer.mockDependencyContainer)
}
