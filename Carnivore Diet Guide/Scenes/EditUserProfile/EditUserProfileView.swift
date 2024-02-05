//
//  EditUserProfileView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/2/24.
//

import SwiftUI
import SwinjectAutoregistration

struct EditUserProfileView: View {
    
    private let imageUploader = iocContainer~>ProfileImageUploader.self
    
    var userId: String
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State var dismissable: Bool = true
    @State private var profileImage: UIImage = .init()
    @State private var fullName: PersonName? = nil
    @State private var username: Username? = nil
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private var isSaveDisabled: Bool {
        profileImage == .init() || fullName == nil || username == nil
    }
    
    private func saveProfileData() async -> TaskStatus {
        //TODO: Fully implement saveProfileData()
        do {
            guard let fullName = fullName else { return .failed("Name is invalid") }
            guard let username = username else { return .failed("Username is invalid") }
            
            let profileImageUrl = try await imageUploader.upload(profileImage: profileImage, for: userId)
            
            let userData = UserData(
                id: userId,
                fullName: fullName,
                username: username,
                profileImageUrl: profileImageUrl
            )
            
            //try await userDataSaver.save(userData: userData)
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
                            ProfileFormPictureField(profileImage: $profileImage)
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
