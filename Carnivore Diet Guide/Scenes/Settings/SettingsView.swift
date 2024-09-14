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
    
    private let signOutService = iocContainer~>UserProfileSignOutService.self
    private let accountDeleter = iocContainer~>UserAccountDeleter.self
    private let notificationService = iocContainer~>NotificationService.self
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var notificationsAreOn: Bool = false
    
    @State private var showResetArticleCacheDialog: Bool = false
    @State private var showLogoutDialog: Bool = false
    @State private var showDeleteAccountDialog: Bool = false
    @State private var showConfirmDeleteAccountSheet: Bool = false
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
    
    private func confirmedLogout() {
        do {
            try signOutService.signOut()
        } catch {
            show(errorMessage: "Unable to logout: \(error.localizedDescription)")
        }
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
                    NotificationsToggleButton()
                    ResetArticleCacheButton()
                }
                Section {
                    LogoutButton()
                    DeleteAccountButton()
                }
                AppVersionRow()
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
        .alert(errorMessage, isPresented: $showError) {}
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
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous))
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
    
    @ViewBuilder func NotificationsToggleButton() -> some View {
        Button {
            notificationService.shouldSendNotifications.toggle()
            withAnimation(.snappy) {
                notificationsAreOn = notificationService.shouldSendNotifications
            }
        } label: {
            HStack {
                ProfileControlLabel(
                    String(localized: "Notifications"),
                    icon: "bell.fill",
                    showNavigationAccessories: false
                )
                Spacer()
                Image(systemName: notificationsAreOn ? "checkmark.square.fill" : "square")
                    .font(.body.bold())
                    .foregroundStyle(notificationsAreOn ? Color.accent: Color.text)
            }
        }
        .listRowBackground(Color.background)
        .onAppear {
            notificationsAreOn = notificationService.shouldSendNotifications
        }
    }
    
    @ViewBuilder func ResetArticleCacheButton() -> some View {
        Button {
            showResetArticleCacheDialog = true
        } label: {
            ProfileControlLabel(
                String(localized: "Reset Article Cache"),
                icon: "memorychip",
                showNavigationAccessories: false
            )
        }
        .listRowBackground(Color.background)
        .confirmationDialog(
            "Are you sure you want to reset the article cache?",
            isPresented: $showResetArticleCacheDialog,
            titleVisibility: .visible
        ) {
            Button("Yes", role: .destructive) {
                let resetter = iocContainer~>ArticleCacheResetter.self
                resetter.resetArticleCache()
            }
        }
    }
    
    @ViewBuilder func LogoutButton() -> some View {
        Button {
            showLogoutDialog = true
        } label: {
            ProfileControlLabel(
                String(localized: "Logout"),
                icon: "iphone.and.arrow.forward",
                showNavigationAccessories: false
            )
        }
        .listRowBackground(Color.background)
        .confirmationDialog(
            "Are you sure you want to logout?",
            isPresented: $showLogoutDialog,
            titleVisibility: .visible
        ) {
            ConfirmLogoutButton()
            CancelLogoutButton()
        }
    }
    
    @ViewBuilder func ConfirmLogoutButton() -> some View {
        Button(role: .destructive) {
            confirmedLogout()
        } label: {
            Text("Logout")
        }
    }
    
    @ViewBuilder func CancelLogoutButton() -> some View {
        Button(role: .cancel) {
        } label: {
            Text("Cancel")
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
        .listRowBackground(Color.background)
        .confirmationDialog(
            "Are you sure you want to delete your account?",
            isPresented: $showDeleteAccountDialog,
            titleVisibility: .visible
        ) {
            ConfirmDeleteAccountButton()
            CancelDeleteAccountButton()
        }
        .sheet(isPresented: $showConfirmDeleteAccountSheet) {
            ConfirmDeleteAccountSheet()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
