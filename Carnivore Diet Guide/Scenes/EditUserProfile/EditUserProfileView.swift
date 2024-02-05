//
//  EditUserProfileView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/2/24.
//

import SwiftUI
import SwinjectAutoregistration

struct EditUserProfileView: View {
    
    //TODO: Dismiss on successful save
    
    private let userDataProvider = iocContainer~>CurrentUserDataProvider.self
    private let imageUploader = iocContainer~>ProfileImageUploader.self
    private let userDataSaver = iocContainer~>UserDataSaver.self
    
    var userId: String
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State var dismissable: Bool = true
    @State private var profileImage: UIImage = .init()
    @State private var profileImageUrl: URL? = nil
    @State private var fullName: PersonName? = nil
    @State private var username: Username? = nil
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func loadExistingUserData() {
        Task {
            do {
                //TODO: Block UI while loading
                let userData = try await userDataProvider.fetchCurrentUserData()
                
                profileImageUrl = userData.profileImageUrl
                fullName = userData.fullName
                username = userData.username
            } catch {
                show(errorMessage: "Could not load existing user data. \(error.localizedDescription)")
            }
        }
    }
    
    private var isSaveDisabled: Bool {
        (profileImage == .init() && profileImageUrl == nil) || fullName == nil || username == nil
    }
    
    private func saveProfileData() async -> TaskStatus {
        do {
            guard let fullName = fullName else { return .failed("Name is invalid") }
            guard let username = username else { return .failed("Username is invalid") }
            
            //TODO: Verify username is available
                        
            var userData = UserData(
                id: userId,
                fullName: fullName,
                username: username
            )
            
            if profileImage != .init() {
                let url = try await imageUploader.upload(profileImage: profileImage, for: userData.id)
                userData.profileImageUrl = url
            }

            try await userDataSaver.save(userData: userData)
            return .success
        } catch {
            return .failed("Unable to save profile data: \(error.localizedDescription)")
        }        
    }
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    TitleBar()
                    ScrollView {
                        VStack(spacing: 16) {
                            ProfileFormPictureField(
                                profileImage: $profileImage,
                                profileImageUrl: profileImageUrl
                            )
                            .padding(.bottom, 16)
                            ProfileFormNameField($fullName)
                            ProfileFormUsernameField($username)
                            Spacer()
                            SaveButton()
                                .padding(.top, 16)
                        }
                        .padding()
                    }
                    .overlay(alignment: .top) {
                        Rectangle()
                            .foregroundStyle(LinearGradient(colors: [.background, .clear], startPoint: .top, endPoint: .bottom))
                            .frame(height: 16)
                    }
                }
            }
            .background(Color.background)
        }
        .interactiveDismissDisabled(!dismissable)
        .presentationDetents([.large])
        .toolbar(.visible, for: .navigationBar)
        .toolbarRole(.automatic)
        .navigationBarBackButtonHidden()
        .alert(errorMessage, isPresented: $showError) {}
        .onAppear {
            loadExistingUserData()
        }
    }
    
    @ViewBuilder func TitleBar() -> some View {
        Text(username == nil ? "Create Profile" : "Edit Profile")
            .bold()
            .foregroundStyle(Color.accent)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .leading) {
                if dismissable {
                    CancelButton()
                }
            }
            .padding()
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .bold()
        }
    }
    
    @ViewBuilder func SaveButton() -> some View {
        TaskAwareButton {
            await saveProfileData()
        } label: {
            Text("Save")
                .foregroundStyle(Color.background)
                .frame(maxWidth: .infinity)
        }
        .disabled(isSaveDisabled)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        Rectangle()
            .sheet(isPresented: .constant(true), content: {
                EditUserProfileView(userId: "userId")
            })
    }
}
