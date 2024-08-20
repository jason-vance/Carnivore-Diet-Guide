//
//  UserProfileView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import SwiftUI
import SwinjectAutoregistration
import Kingfisher

struct UserProfileView: View {
    
    let userId: String
    
    @StateObject private var model = UserProfileViewModel(
        userDataProvider: iocContainer~>UserDataProvider.self,
        signOutService: iocContainer~>UserProfileSignOutService.self
    )
    
    @State private var showEditProfile: Bool = false
    @State private var showLogoutDialog: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func confirmedLogout() {
        do {
            try model.signOut()
        } catch {
            show(errorMessage: "Unable to logout: \(error.localizedDescription)")
        }
    }
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScreenTitleBar(model.fullName ?? String(localized: "User Profile"))
                ScrollView {
                    VStack {
                        ProfileImage()
                        VStack {
                            EditProfileButton()
//                            FavoriteRecipesButton()
//                            BookmarkedArticlesButton()
                            SettingsButton()
                        }
                        .padding(.bottom, 32)
                        LogoutButton()
                    }
                    .padding()
                }
            }
            .background(Color.background)
        }
        .alert(errorMessage, isPresented: $showError) {}
        .confirmationDialog(
            "Are you sure you want to logout?",
            isPresented: $showLogoutDialog,
            titleVisibility: .visible
        ) {
            ConfirmLogoutButton()
            CancelLogoutButton()
        }
        .sheet(isPresented: $showEditProfile) {
            EditUserProfileView(userId: userId)
        }
        .onChange(of: userId, initial: true) {
            model.listenForUserData(userId: userId)
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
    
    @ViewBuilder func ProfileImage() -> some View {
        ProfileImageView(model.profileImageUrl)
    }
    
    @ViewBuilder func EditProfileButton() -> some View {
        Button {
            showEditProfile = true
        } label: {
            ProfileControlLabel(
                String(localized: "Edit Profile"),
                icon: "person.fill",
                showNavigationAccessories: true
            )
        }
    }
    
    @ViewBuilder func FavoriteRecipesButton() -> some View {
        ProfileNavigationLink(
            String(localized: "Favorite Recipes"),
            icon: "heart.fill"
        ) {
            Text("Favorite Recipes")
        }
    }
    
    @ViewBuilder func BookmarkedArticlesButton() -> some View {
        ProfileNavigationLink(
            String(localized: "Bookmarked Articles"),
            icon: "bookmark.fill"
        ) {
            Text("Favorite Recipes")
        }
    }
    
    @ViewBuilder func SettingsButton() -> some View {
        ProfileNavigationLink(
            String(localized: "Settings"),
            icon: "gearshape.fill"
        ) {
            SettingsView()
        }
    }
    
    @ViewBuilder func LogoutButton() -> some View {
        ProfileButton(
            String(localized: "Logout"),
            icon: "iphone.and.arrow.forward"
        ) {
            showLogoutDialog = true
        }
    }
    
    @ViewBuilder func ProfileNavigationLink<Content>(
        _ title: String,
        icon: String,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        NavigationLink {
            content()
        } label: {
            ProfileControlLabel(title, icon: icon, showNavigationAccessories: true)
        }
    }
    
    @ViewBuilder func ProfileButton(
        _ title: String,
        icon: String,
        action: @escaping () -> ()
    ) -> some View {
        Button {
            action()
        } label: {
            ProfileControlLabel(title, icon: icon, showNavigationAccessories: false)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        UserProfileView(userId: "userId")
    }
}
