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
    
    private enum Field: Hashable {
        case bio
    }
    
    let userId: String
    
    @StateObject private var model = UserProfileViewModel(
        currentUserIdProvider: iocContainer~>CurrentUserIdProvider.self,
        userDataProvider: iocContainer~>UserDataProvider.self,
        userDataSaver: iocContainer~>UserDataSaver.self,
        isAdminChecker: iocContainer~>IsAdminChecker.self
    )
    
    @State private var navigationPath = NavigationPath()
    
    @State private var userBio: String = ""
    
    @FocusState private var focusedField: Field?
    
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
                    if showAds { AdRow() }
                    PicPostsAndOtherStats()
                    ProfileControls()
                        .padding(.bottom)
                    BioField()
                }
                .padding(.bottom)
            }
        }
        .background(Color.background)
        .alert(errorMessage, isPresented: $showError) {}
        .onReceive(showAdsPublisher) { showAds = $0 }
        .onChange(of: userId, initial: true) { _, newUserId in
            model.listenForUserData(userId: newUserId)
        }
        .onChange(of: model.userData.bio?.value, initial: true) { _, newBio in
            userBio = newBio ?? ""
        }
    }
    
    @ViewBuilder func TopBar() -> some View {
        ScreenTitleBar(
            model.screenTitle,
            trailingContent: SettingsButton
        )
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
    
    @ViewBuilder func ProfileControls() -> some View {
        if let isMe = model.isMe {
            if isMe {
                ControlsForMyProfile()
            } else {
                ControlsForOthersProfile()
            }
        }
    }
    
    @ViewBuilder func ControlsForMyProfile() -> some View {
        HStack {
            EditProfileButton()
            if model.isAdmin {
                AdminButton()
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func ControlsForOthersProfile() -> some View {
        HStack {
            //TODO: FollowButton()
            Spacer()
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
    
    @ViewBuilder func BioField() -> some View {
        if let isMe = model.isMe, isMe {
            BioFieldForMe()
        } else if let bio = model.userData.bio {
            BioFieldForOthers(bio)
        }
    }
    
    @ViewBuilder func BioFieldForMe() -> some View {
        PropertyField(name: String(localized: "Bio")) {
            VStack(spacing: 0) {
                TextField(
                    "Tell us about yourself",
                    text: $userBio,
                    prompt: Text("Tell us about yourself").foregroundStyle(Color.text.opacity(0.3)),
                    axis: .vertical
                )
                .textInputAutocapitalization(.sentences)
                .focused($focusedField, equals: Field.bio)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button {
                            focusedField = nil
                            model.save(userBio: userBio)
                        } label: {
                            Text("Done")
                                .foregroundStyle(Color.accent)
                                .bold()
                        }
                    }
                }
                HStack {
                    Spacer()
                    Text("\(userBio.count)/\(UserBio.maxLength)")
                        .font(.caption2)
                        .foregroundStyle(userBio.count > UserBio.maxLength ? Color.accentColor : Color.text)
                        .opacity(userBio.count > UserBio.maxLength ? 1 : focusedField == .bio ? 0.5 : 0)
                }
            }
        }
    }
    
    @ViewBuilder func BioFieldForOthers(_ bio: UserBio) -> some View {
        PropertyField(name: String(localized: "Bio")) {
            HStack {
                Text(bio.value)
                Spacer()
            }
        }
    }
    
    @ViewBuilder func PropertyField<Content:View>(name: String, content: () -> Content) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .font(.footnote.bold())
                Spacer()
            }
            content()
        }
        .foregroundStyle(Color.text)
        .font(.body)
        .padding(.horizontal)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        UserProfileView(userId: "userId")
    }
}
