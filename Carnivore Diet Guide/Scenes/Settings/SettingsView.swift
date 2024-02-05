//
//  SettingsView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var showDeleteAccountDialog: Bool = false
    @State private var showConfirmDeleteAccountDialog: Bool = false
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
    
    private func confirmDeleteAccount() {
        if showConfirmDeleteAccountDialog {
            Task {
                do {
                    try await actuallyDeleteAccount()
                } catch {
                    show(errorMessage: "Could not delete account: \(error.localizedDescription)")
                }
            }
        } else {
            showConfirmDeleteAccountDialog = true
        }
    }
    
    private func actuallyDeleteAccount() async throws {
        //TODO: Implement deleteAccount
        print("Delete")
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TitleBar()
                ScrollView {
                    VStack {
                        DeleteAccountButton()
                    }
                    .padding()
                }
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color.background, Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 16)
                }
            }
            .background(Color.background)
        }
        .toolbar(.hidden, for: .automatic)
        .alert(errorMessage, isPresented: $showError) {}
        .confirmationDialog(
            "Are you sure you want to delete your account?",
            isPresented: $showDeleteAccountDialog,
            titleVisibility: .visible
        ) {
            ConfirmDeleteAccountButton()
            CancelDeleteAccountButton()
        }
        .confirmationDialog(
            "Are you really sure you want to delete your account? This action will delete all of your data and is irreversible.",
            isPresented: $showConfirmDeleteAccountDialog,
            titleVisibility: .visible
        ) {
            ConfirmDeleteAccountButton()
            CancelDeleteAccountButton()
        }
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
        } label: {
            Text("Cancel")
        }
    }
    
    @ViewBuilder func TitleBar() -> some View {
        Text("Settings")
            .bold()
            .foregroundStyle(Color.text)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .leading) {
                BackButton()
            }
            .padding()
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.backward")
                .bold()
        }
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
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
