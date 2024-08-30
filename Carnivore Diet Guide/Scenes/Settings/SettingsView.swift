//
//  SettingsView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import SwiftUI
import SwinjectAutoregistration
import _AuthenticationServices_SwiftUI

struct SettingsView: View {
    
    private let accountDeleter = iocContainer~>UserAccountDeleter.self
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var showDeleteAccountDialog: Bool = false
    @State private var showConfirmDeleteAccountSheet: Bool = false
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
    
    private func confirmDeleteAccount() {
        showConfirmDeleteAccountSheet = true
    }
    
    private func actuallyDeleteAccount(authResult: Result<ASAuthorization, Error>) {
        showConfirmDeleteAccountSheet = false
        Task {
            do {        
                switch authResult {
                case .success(let authorization):
                    try await accountDeleter.deleteCurrentUserAccount(authorization: authorization)
                case .failure(let error):
                    throw error
                }
            } catch {
                let errorMessage = "Account could not be deleted: \(error.localizedDescription)"
                print(errorMessage)
                show(errorMessage: errorMessage)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar()
            List {
                Section {
                    DeleteAccountButton()
                }
                AppVersionRow()
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
        .alert(errorMessage, isPresented: $showError) {}
        .confirmationDialog(
            "Are you sure you want to delete your account?",
            isPresented: $showDeleteAccountDialog,
            titleVisibility: .visible
        ) {
            ConfirmDeleteAccountButton()
            CancelDeleteAccountButton()
        }
        .sheet(isPresented: $showConfirmDeleteAccountSheet, content: {
            ConfirmDeleteAccountSheet()
        })
    }
    
    @ViewBuilder func TitleBar() -> some View {
        ScreenTitleBar(
            String(localized: "Settings"),
            leadingContent: BackButton
        )
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "chevron.backward")
        }
    }
    
    @ViewBuilder func ConfirmDeleteAccountSheet() -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [.clear, .text], startPoint: .top, endPoint: .bottom) 
                .ignoresSafeArea()
                .onTapGesture {
                    showConfirmDeleteAccountSheet = false
                }
            VStack {
                Text("Are you really sure you want to delete your account? This action will delete all of your data and is irreversible.")
                    .foregroundStyle(Color.text)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                ReallyConfirmDeleteAccountButton()
                CancelDeleteAccountButton()
            }
            .padding()
            .background(Color.background)
            .clipShape(RoundedRectangle(cornerRadius: Corners.radius, style: .continuous))
            .padding()
        }
        .presentationCompactAdaptation(.fullScreenCover)
        .presentationBackground(.clear)
    }
    
    @ViewBuilder func ReallyConfirmDeleteAccountButton() -> some View {
        SignInWithAppleButton(.continue) { _ in
        } onCompletion: { result in
            actuallyDeleteAccount(authResult: result)
        }
        .frame(height: 48)
        .padding(.vertical)
    }
    
    @ViewBuilder func ConfirmDeleteAccountButton() -> some View {
        Button(role: .destructive) {
            confirmDeleteAccount()
        } label: {
            Text("Delete Account")
        }
    }
    
    @ViewBuilder func CancelDeleteAccountButton() -> some View {
        Button(role: .cancel) {
            showDeleteAccountDialog = false
            showConfirmDeleteAccountSheet = false
        } label: {
            Text("Cancel")
        }
        .frame(height: 48)
    }
    
    @ViewBuilder func DeleteAccountButton() -> some View {
        Button {
            showDeleteAccountDialog = true
        } label: {
            ProfileControlLabel(
                String(localized: "Delete Account"),
                icon: "trash.fill",
                showNavigationAccessories: false
            )
        }
        .listRowBackground(Color.background)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
