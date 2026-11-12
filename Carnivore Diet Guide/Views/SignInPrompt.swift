//
//  SignInPrompt.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import AuthenticationServices
import SwinjectAutoregistration

/// Asks a guest to sign in with Apple before doing something that needs an account. Signing in
/// upgrades the guest's anonymous account, and ContentView swaps to the signed-in app on success.
struct SignInPrompt: View {

    let reason: String
    /// When set, a "Not Now" button is shown that calls this.
    var onDismiss: (() -> Void)? = nil

    private let authProvider = iocContainer~>SignInAuthenticationProvider.self

    @Environment(\.colorScheme) private var colorScheme

    @State private var isWorking = false
    @State private var showError = false
    @State private var errorMessage = ""

    private func signIn(withResult result: Result<ASAuthorization, Error>) {
        if case .failure(let error) = result, (error as? ASAuthorizationError)?.code == .canceled {
            return
        }
        isWorking = true
        Task {
            do {
                try await authProvider.signIn(withResult: result)
            } catch {
                errorMessage = String(localized: "Unable to sign in: \(error.localizedDescription)")
                showError = true
            }
            isWorking = false
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 44))
                .foregroundStyle(Color.accentColor)
            Text("Sign in to Carnivore Diet Guide")
                .font(.headline)
                .foregroundStyle(Color.text)
            Text(reason)
                .font(.subheadline)
                .foregroundStyle(Color.text.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                signIn(withResult: result)
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 48)
            .disabled(isWorking)
            .overlay { if isWorking { ProgressView() } }
            .padding(.top, 4)
            if let onDismiss {
                Button("Not Now", action: onDismiss)
                    .foregroundStyle(Color.accentColor)
                    .disabled(isWorking)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .alert(errorMessage, isPresented: $showError) {}
    }
}

extension View {
    /// Presents a `SignInPrompt` in a sheet. Use for actions a guest can't take without an account.
    func signInPrompt(isPresented: Binding<Bool>, reason: String) -> some View {
        sheet(isPresented: isPresented) {
            SignInPrompt(reason: reason) { isPresented.wrappedValue = false }
                .padding(24)
                .presentationBackground(Color.background)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        SignInPrompt(reason: "Sign in to save your favorite articles and recipes.") { }
            .padding()
            .background(Color.background)
    }
}
