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
        isAdminChecker: iocContainer~>IsAdminChecker.self
    )
    
    @State private var navigationPath = NavigationPath()
    
    @State private var showPosts: Bool = false
    @State private var showEditProfile: Bool = false
    @State private var showSettings: Bool = false
    @State private var showAdmin: Bool = false
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var showAds: Bool = false
    private var showAdsPublisher: AnyPublisher<Bool,Never> {
        (iocContainer~>AdProvider.self)
            .showAdsPublisher
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            ScrollView {
                VStack {
                    PicPostsAndOtherStats()
                    HStack {
                        EditProfileButton()
                        if model.isAdmin {
                            AdminButton()
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    if showAds { AdRow() }
                }
                .padding(.vertical)
            }
        }
        .background(Color.background)
        .alert(errorMessage, isPresented: $showError) {}
        .onReceive(showAdsPublisher) { showAds = $0 }
        .onChange(of: userId, initial: true) { _, newUserId in
            model.listenForUserData(userId: newUserId)
        }
    }
    
    @ViewBuilder func TopBar() -> some View {
        ScreenTitleBar(
            model.screenTitle,
            trailingContent: SettingsButton
        )
    }
    
    @ViewBuilder func PicPostsAndOtherStats() -> some View {
        VStack {
            HStack {
                ProfileImage()
                PostCountButton()
                Spacer()
            }
            if let fullName = model.userData.fullName {
                HStack {
                    UserFullName(fullName)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func UserFullName(_ name: PersonName) -> some View {
        Text(name.value)
            .foregroundStyle(Color.text)
            .font(.callout.bold())
    }
    
    @ViewBuilder func ProfileImage() -> some View {
        ProfileImageView(
            model.profileImageUrl,
            size: nil,
            padding: .borderWidthMedium
        )
        .containerRelativeFrame(.horizontal, count: 4, spacing: 0)
    }
    
    @ViewBuilder func PostCountButton() -> some View {
        Button {
            showPosts = true
        } label: {
            PostCountStatView(userId: userId)
        }
        .containerRelativeFrame(.horizontal, count: 4, spacing: 0)
        .fullScreenCover(isPresented: $showPosts) {
            PostsView(userData: model.userData)
        }
    }
    
    @ViewBuilder func UserProfileButtonLabel(text: String, imageName: String) -> some View {
        HStack {
            Image(systemName: imageName)
            Text(text)
        }
        .font(.footnote.bold())
        .foregroundStyle(Color.accent)
        .padding(.horizontal, .paddingHorizontalButtonMedium)
        .padding(.vertical, .paddingVerticalButtonSmall)
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                .foregroundStyle(Color.accent.opacity(0.1))
        }
    }
    
    @ViewBuilder func EditProfileButton() -> some View {
        Button {
            showEditProfile = true
        } label: {
            UserProfileButtonLabel(
                text: String(localized: "Edit Profile"),
                imageName: "person.fill"
            )
        }
        .sheet(isPresented: $showEditProfile) {
            EditUserProfileView(userId: userId, mode: .editProfile)
        }
    }
    
    @ViewBuilder func SettingsButton() -> some View {
        Button {
            showSettings = true
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "gearshape.fill")
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    @ViewBuilder func AdminButton() -> some View {
        Button {
            showAdmin = true
        } label: {
            UserProfileButtonLabel(
                text: String(localized: "Admin"),
                imageName: "lock.shield.fill"
            )
        }
        .fullScreenCover(isPresented: $showAdmin) {
            AdminView()
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
