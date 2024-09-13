//
//  UserProfileView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Combine
import SwiftUI
import SwinjectAutoregistration
import Kingfisher

struct UserProfileView: View {
    
    let userId: String
    
    @StateObject private var model = UserProfileViewModel(
        userDataProvider: iocContainer~>UserDataProvider.self,
        signOutService: iocContainer~>UserProfileSignOutService.self,
        isAdminChecker: iocContainer~>IsAdminChecker.self
    )
    
    @State private var navigationPath = NavigationPath()
    
    @State private var showPosts: Bool = false
    @State private var showEditProfile: Bool = false
    @State private var showSettings: Bool = false
    @State private var showAdmin: Bool = false
    @State private var showLogoutDialog: Bool = false
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var showAds: Bool = false
    private var showAdsPublisher: AnyPublisher<Bool,Never> {
        (iocContainer~>AdProvider.self)
            .showAdsPublisher
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
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
        VStack(spacing: 0) {
            ScreenTitleBar(model.screenTitle)
            ScrollView {
                VStack {
                    ProfileImage()
                    if showAds { AdRow() }
                    VStack {
                        ProfileStatsView()
                        EditProfileButton()
                        SettingsButton()
                        if model.isAdmin {
                            AdminButton()
                        }
                        LogoutButton()
                            .padding(.top)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .padding(.vertical)
            }
        }
        .background(Color.background)
        .alert(errorMessage, isPresented: $showError) {}
        .onReceive(showAdsPublisher) { showAds = $0 }
        .confirmationDialog(
            "Are you sure you want to logout?",
            isPresented: $showLogoutDialog,
            titleVisibility: .visible
        ) {
            ConfirmLogoutButton()
            CancelLogoutButton()
        }
        .sheet(isPresented: $showEditProfile) {
            EditUserProfileView(userId: userId, mode: .editProfile)
        }
        .onChange(of: userId, initial: true) {
            model.listenForUserData(userId: userId)
        }
        .fullScreenCover(isPresented: $showPosts) {
            PostsView(userData: model.userData)
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
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
    
    @ViewBuilder func ProfileStatsView() -> some View {
        HStack {
            PostCountButton()
        }
        .padding()
    }
    
    @ViewBuilder func PostCountButton() -> some View {
        Button {
            showPosts = true
        } label: {
            PostCountStatView(userId: userId)
        }
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
    
    @ViewBuilder func SettingsButton() -> some View {
        Button {
            showSettings = true
        } label: {
            ProfileControlLabel(
                String(localized: "Settings"),
                icon: "gearshape.fill",
                showNavigationAccessories: true
            )
        }
    }
    
    @ViewBuilder func AdminButton() -> some View {
        Button {
            showAdmin = true
        } label: {
            ProfileControlLabel(
                String(localized: "Admin"),
                icon: "lock.shield.fill",
                showNavigationAccessories: true
            )
        }
        .fullScreenCover(isPresented: $showAdmin) {
            AdminView()
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
