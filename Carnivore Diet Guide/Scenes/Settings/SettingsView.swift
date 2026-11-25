//
//  SettingsView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import SwiftUI
import StoreKit
import SwinjectAutoregistration
import _AuthenticationServices_SwiftUI

struct SettingsView: View {
    
    private let signOutService = iocContainer~>UserProfileSignOutService.self
    private let accountDeleter = iocContainer~>UserAccountDeleter.self
    private let notificationService = iocContainer~>NotificationService.self
    @ObservedObject private var subscriptionLevelProvider = iocContainer~>SubscriptionLevelProvider.self

    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var notificationsAreOn: Bool = false
    
    @State private var showResetArticleCacheDialog: Bool = false
    @State private var showResetRecipeCacheDialog: Bool = false
    @State private var showTermsOfService: Bool = false
    @State private var showPrivacyPolicy: Bool = false
    @State private var showLogoutDialog: Bool = false
    @State private var showDeleteAccountDialog: Bool = false
    @State private var showConfirmDeleteAccountSheet: Bool = false
    @State private var showManageSubscriptions: Bool = false

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSignInPrompt: Bool = false

    private var isGuest: Bool {
        (iocContainer~>CurrentUserIdProvider.self).currentUserId == nil
    }

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
        switch authResult {
        case .success(let authorization):
            actuallyDeleteAccount(reauthentication: .apple(authorization))
        case .failure(let error):
            showConfirmDeleteAccountSheet = false
            if (error as? ASAuthorizationError)?.code == .canceled { return }
            show(errorMessage: "Account could not be deleted: \(error.localizedDescription)")
        }
    }

    private func actuallyDeleteAccount(reauthentication: AccountReauthentication) {
        showConfirmDeleteAccountSheet = false
        Task {
            do {
                try await accountDeleter.deleteCurrentUserAccount(reauthentication: reauthentication)
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
                Section("App") {
                    NotificationsToggleButton()
                    ResetArticleCacheButton()
                    ResetRecipeCacheButton()
                }
                if let source = subscriptionLevelProvider.carnivorePlusSource {
                    Section("Carnivore+") {
                        CarnivorePlusBillingRow(source: source)
                    }
                }
                Section("Legal") {
                    TermsOfServiceButton()
                    PrivacyPolicyButton()
                }
                Section("Account") {
                    if isGuest {
                        SignInButton()
                    } else {
                        LogoutButton()
                        DeleteAccountButton()
                    }
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
                if subscriptionLevelProvider.carnivorePlusSource != nil {
                    Text("Deleting your account doesn't cancel Carnivore+. Cancel it where you subscribed if you don't want it to renew.")
                        .font(.footnote)
                        .foregroundStyle(Color.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
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
    
    /// Deleting needs a fresh sign-in, so offer each way this account signs in.
    @ViewBuilder func ReallyConfirmDeleteAccountButton() -> some View {
        let signInMethods = accountDeleter.signInMethods
        VStack(spacing: 12) {
            if signInMethods.contains(.apple) || !signInMethods.contains(.google) {
                SignInWithAppleButton(.continue) { _ in
                } onCompletion: { result in
                    actuallyDeleteAccount(authResult: result)
                }
                .frame(height: 48)
            }
            if signInMethods.contains(.google) {
                ContinueWithGoogleButton {
                    actuallyDeleteAccount(reauthentication: .google)
                }
                .frame(height: 48)
            }
        }
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
            iocContainer.resolve(ProgramStore.self)?.rescheduleReminders()
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
    
    @ViewBuilder func ResetRecipeCacheButton() -> some View {
        Button {
            showResetRecipeCacheDialog = true
        } label: {
            ProfileControlLabel(
                String(localized: "Reset Recipe Cache"),
                icon: "memorychip",
                showNavigationAccessories: false
            )
        }
        .listRowBackground(Color.background)
        .confirmationDialog(
            "Are you sure you want to reset the recipe cache?",
            isPresented: $showResetRecipeCacheDialog,
            titleVisibility: .visible
        ) {
            Button("Yes", role: .destructive) {
                let resetter = iocContainer~>RecipeCacheResetter.self
                resetter.resetRecipeCache()
            }
        }
    }
    
    /// Where Carnivore+ is billed. A subscription from the web or the Android app is managed there, so this
    /// only says where; it never links out to buy.
    @ViewBuilder private func CarnivorePlusBillingRow(source: CarnivorePlusSource) -> some View {
        switch source {
        case .appStore:
            Button {
                showManageSubscriptions = true
            } label: {
                ProfileControlLabel(
                    String(localized: "Manage Subscription"),
                    icon: "creditcard.fill",
                    showNavigationAccessories: false
                )
            }
            .listRowBackground(Color.background)
            .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
        case .stripe:
            CarnivorePlusBilledElsewhereRow(
                String(localized: "Billed through the web"),
                detail: String(localized: "Manage your subscription by signing in at carnivoredietguide.com.")
            )
        case .googlePlay:
            CarnivorePlusBilledElsewhereRow(
                String(localized: "Billed through Google Play"),
                detail: String(localized: "Manage your subscription in the Play Store on your Android device.")
            )
        }
    }

    @ViewBuilder private func CarnivorePlusBilledElsewhereRow(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileControlLabel(title, icon: "creditcard.fill", showNavigationAccessories: false)
            Text(detail)
                .font(.footnote)
                .foregroundStyle(Color.text.opacity(0.7))
                .padding(.leading, 32)
                .padding(.bottom, 8)
        }
        .listRowBackground(Color.background)
    }

    @ViewBuilder private func TermsOfServiceButton() -> some View {
        Button {
            showTermsOfService = true
        } label: {
            ProfileControlLabel(
                String(localized: "Terms of Service"),
                icon: "scroll.fill",
                showNavigationAccessories: false
            )
        }
        .sheet(isPresented: $showTermsOfService) {
            TextWall(TermsOfService.markdownContent)
                .presentationDragIndicator(.visible)
        }
        .listRowBackground(Color.background)
    }
    
    @ViewBuilder private func PrivacyPolicyButton() -> some View {
        Button {
            showPrivacyPolicy = true
        } label: {
            ProfileControlLabel(
                String(localized: "Privacy Policy"),
                icon: "lock.shield.fill",
                showNavigationAccessories: false
            )
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            TextWall(PrivacyPolicy.markdownContent)
                .presentationDragIndicator(.visible)
        }
        .listRowBackground(Color.background)
    }
    
    @ViewBuilder func SignInButton() -> some View {
        Button {
            showSignInPrompt = true
        } label: {
            ProfileControlLabel(
                String(localized: "Sign In"),
                icon: "person.crop.circle.badge.plus",
                showNavigationAccessories: false
            )
        }
        .listRowBackground(Color.background)
        .signInPrompt(
            isPresented: $showSignInPrompt,
            reason: String(localized: "Sign in to save favorites, join the comments, and set up your profile.")
        )
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
