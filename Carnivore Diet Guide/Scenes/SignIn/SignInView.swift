//
//  SignInView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import SwiftUI
import _AuthenticationServices_SwiftUI
import SwinjectAutoregistration
import Combine

struct SignInView: View {
    
    private let authProvider = iocContainer~>SignInAuthenticationProvider.self
    
    @State var userAuthState: UserAuthState = .working
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
    
    private func signIn(withResult result: Result<ASAuthorization, Error>) {
        Task {
            do {
                try await authProvider.signIn(withResult: result)
            } catch {
                show(errorMessage: "Unable to sign in: \(error.localizedDescription)")
            }
        }
    }
    
    private func continueAsGuest() {
        Task {
            do {
                try await authProvider.signInAsGuest()
            } catch {
                show(errorMessage: String(localized: "Unable to continue as a guest: \(error.localizedDescription)"))
            }
        }
    }

    var body: some View {
        VStack {
            Spacer()
            AppTitle()
            Spacer()
            SignInControls()
        }
        .frame(maxWidth: .infinity)
        .background(Color.accent)
        .alert(errorMessage, isPresented: $showError) {}
        .onReceive(authProvider.userAuthStatePublisher) { newAuthState in
            withAnimation(.snappy) {
                userAuthState = newAuthState
            }
        }
    }
    
    @ViewBuilder func SignInControls() -> some View {
        if userAuthState == .loggedOut {
            VStack(spacing: 0) {
                SignInButton()
                ContinueAsGuestButton()
            }
        } else {
            ProgressSpinner()
        }
    }
    
    @ViewBuilder func AppTitle() -> some View {
        VStack {
            Text("Carnivore", comment: "First line of the app name on the home screen. ie\n\"Carnivore\nDiet Guide\"")
                .font(.system(size: 54, weight: .black))
                .multilineTextAlignment(.center)
                .foregroundColor(.background)
            Text("Diet Guide", comment: "Second line of the app name on the home screen. ie\n\"Carnivore\nDiet Guide\"")
                .font(.system(size: 48, weight: .black))
                .multilineTextAlignment(.center)
                .foregroundColor(.background)
        }
        .padding()
    }
    
    @ViewBuilder func SignInButton() -> some View {
        SignInWithAppleButton(.continue) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            signIn(withResult: result)
        }
        .signInWithAppleButtonStyle(.white)
        .frame(height: 48)
        .padding()
    }

    @ViewBuilder func ContinueAsGuestButton() -> some View {
        Button {
            continueAsGuest()
        } label: {
            Text("Continue as Guest")
                .font(.headline)
                .foregroundStyle(Color.background)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    @ViewBuilder func ProgressSpinner() -> some View {
        ProgressView()
            .tint(Color.background)
            .frame(height: 48)
            .padding()
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        SignInView()
    }
}
