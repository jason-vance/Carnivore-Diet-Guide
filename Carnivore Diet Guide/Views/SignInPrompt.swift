//
//  SignInPrompt.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import AuthenticationServices
import SwinjectAutoregistration

/// Asks a guest to sign in with Apple or Google before doing something that needs an account. Signing in
/// upgrades the guest's anonymous account, and ContentView swaps to the signed-in app on success.
struct SignInPrompt: View {

    let reason: String
    /// When set, a "Not Now" button is shown that calls this.
    var onDismiss: (() -> Void)? = nil

    private let authProvider = iocContainer~>SignInAuthenticationProvider.self

    @Environment(\.colorScheme) private var colorScheme

    /// The sign-in in progress, if any. Its button shows a spinner and all the buttons are disabled.
    @State private var working: SignInMethod?
    private var isWorking: Bool { working != nil }
    @State private var showError = false
    @State private var errorMessage = ""

    private func signIn(withResult result: Result<ASAuthorization, Error>) {
        if case .failure(let error) = result, (error as? ASAuthorizationError)?.code == .canceled {
            return
        }
        working = .apple
        Task {
            do {
                try await authProvider.signIn(withResult: result)
            } catch {
                errorMessage = String(localized: "Unable to sign in: \(error.localizedDescription)")
                showError = true
            }
            working = nil
        }
    }

    private func signInWithGoogle() {
        working = .google
        Task {
            do {
                try await authProvider.signInWithGoogle()
            } catch {
                errorMessage = String(localized: "Unable to sign in: \(error.localizedDescription)")
                showError = true
            }
            working = nil
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
            .overlay { if working == .apple { ProgressView() } }
            .padding(.top, 4)
            ContinueWithGoogleButton(style: colorScheme == .dark ? .dark : .light) {
                signInWithGoogle()
            }
            .frame(height: 48)
            .disabled(isWorking)
            .overlay { if working == .google { ProgressView() } }
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
            SignInPromptSheet(reason: reason) { isPresented.wrappedValue = false }
        }
    }
}

/// A `SignInPrompt` in a sheet exactly as tall as the prompt, so nothing is cut off on small phones
/// or with large text.
private struct SignInPromptSheet: View {

    let reason: String
    let onDismiss: () -> Void

    @State private var height: CGFloat = 400

    var body: some View {
        SignInPrompt(reason: reason, onDismiss: onDismiss)
            .padding(24)
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { newHeight in
                height = newHeight
            }
            .presentationBackground(Color.background)
            .presentationDetents([.height(height)])
            .presentationDragIndicator(.visible)
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
