//
//  LoginView.swift
//  TestLearning
//
//  Created by Vijendran  on 5/9/26.
//

import SwiftUI

struct LoginView: View {
    enum Fields: Hashable { case email, password }

    @State private var viewModel: LoginViewModel
    @FocusState private var focusField: Fields?

    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sign in")
                .font(.largeTitle.bold())
                .padding(.bottom, 10)
            
            TextField("Email", text: $viewModel.email)
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

            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .foregroundStyle(.black)
                .textContentType(.password)
                .submitLabel(.done)
                .focused($focusField, equals: .password)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button {
                focusField = nil
                Task {
                    await viewModel.login()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                } else {
                    Text("Login")
                        .padding()
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(viewModel.isLoading)
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
        .onAppear {
            focusField = .email
        }
    }
}

#Preview {
    let dependencies = DependencyContainer.mockDependencyContainer
    let factory = ViewFactory(dependencies: dependencies)
    return factory.makeLoginView()
        .environment(dependencies)
        .environment(factory)
}
