//
//  EditUserProfileView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/2/24.
//

import MarkdownUI
import SwiftUI
import SwinjectAutoregistration

struct EditUserProfileView: View {
    
    enum Mode {
        case createProfile
        case editProfile
    }
    
    private enum InitializationState {
        case notInitialized
        case initialized
    }
    
    private let userDataProvider = iocContainer~>CurrentUserDataProvider.self
    private let imageUploader = iocContainer~>ProfileImageUploader.self
    private let userDataSaver = iocContainer~>UserDataSaver.self
    
    var userId: String
    var mode: Mode
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var profileImage: UIImage = .init()
    @State private var profileImageUrl: URL? = nil
    @State private var fullName: PersonName? = nil
    @State private var username: Username? = nil
    @State private var termsOfServiceAcceptance: Date? = nil
    @State private var privacyPolicyAcceptance: Date? = nil
    @State private var initializationState: InitializationState = .notInitialized

    @State private var showTermsOfService: Bool = false
    @State private var showPrivacyPolicy: Bool = false
    @State private var showBlockingSpinner: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func loadExistingUserData() {
        Task {
            do {
                let userData = try await userDataProvider.fetchCurrentUserData()
                
                profileImageUrl = userData.profileImageUrl
                fullName = userData.fullName
                //TODO: Populate ToS and PP so that saving is not disabled
                
                initializationState = .initialized
            } catch {
                show(errorMessage: "Could not load existing user data. \(error.localizedDescription)")
            }
        }
    }
    
    private var isSaveDisabled: Bool {
        (profileImage == .init() && profileImageUrl == nil) || 
        fullName == nil ||
        termsOfServiceAcceptance == nil ||
        privacyPolicyAcceptance == nil
    }
    
    private func saveProfileData() async -> TaskStatus {
        do {
            guard let fullName = fullName else { return .failed("Name is invalid") }
            guard let termsOfServiceAcceptance = termsOfServiceAcceptance else { return .failed("Please agree to the Terms of Service") }
            guard let privacyPolicyAcceptance = privacyPolicyAcceptance else { return .failed("Please accept the Privacy Policy") }

            var userData = UserData(
                id: userId,
                fullName: fullName,
                termsOfServiceAcceptance: termsOfServiceAcceptance,
                privacyPolicyAcceptance: privacyPolicyAcceptance
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
        InitializedView()
            .overlay {
                if initializationState == .notInitialized {
                    BlockingSpinnerView()
                }
            }
            .alert(errorMessage, isPresented: $showError) {}
            .onChange(of: initializationState, initial: true) { newState in
                withAnimation(.snappy) {
                    showBlockingSpinner = newState == .notInitialized
                }
            }
            .onAppear {
                loadExistingUserData()
            }
    }
    
    @ViewBuilder func InitializedView() -> some View {
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
                        if mode == .createProfile {
                            VStack(spacing: 0) {
                                TermsOfServiceField()
                                PrivacyPolicyField()
                            }
                        }
                        Spacer()
                        SaveButton()
                            .padding(.top, 16)
                    }
                    .padding()
                }
            }
        }
        .background(Color.background)
    }
    
    @ViewBuilder func TitleBar() -> some View {
        if mode == .createProfile {
            ScreenTitleBar("Create Profile")
        } else {
            ScreenTitleBar("Edit Profile", leadingContent: CancelButton)
        }
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .bold()
        }
    }
    
    @ViewBuilder func TermsOfServiceField() -> some View {
        let message: AttributedString = {
            var text = AttributedString("I agree to the Terms of Service.")
            text.foregroundColor = Color.text
            guard let range = text.range(of: "Terms of Service") else { return text }
            text[range].foregroundColor = Color.accent

            return text
        }()
        
        HStack {
            Button {
                if termsOfServiceAcceptance == nil {
                    termsOfServiceAcceptance = .now
                } else {
                    termsOfServiceAcceptance = nil
                }
            } label: {
                let isAccepted = termsOfServiceAcceptance != nil
                Image(systemName: isAccepted ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isAccepted ? Color.accent : Color.text)
                    .padding(.vertical)
            }
            Button {
                showTermsOfService = true
            } label: {
                Text(message)
            }
            .sheet(isPresented: $showTermsOfService) {
                TextWall(TermsOfService.markdownContent)
            }
            Spacer()
        }
    }
    
    @ViewBuilder func PrivacyPolicyField() -> some View {
        let message: AttributedString = {
            var text = AttributedString("I accept the Privacy Policy.")
            text.foregroundColor = Color.text
            guard let range = text.range(of: "Privacy Policy") else { return text }
            text[range].foregroundColor = Color.accent

            return text
        }()
        
        HStack {
            Button {
                if privacyPolicyAcceptance == nil {
                    privacyPolicyAcceptance = .now
                } else {
                    privacyPolicyAcceptance = nil
                }
            } label: {
                let isAccepted = privacyPolicyAcceptance != nil
                Image(systemName: isAccepted ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isAccepted ? Color.accent : Color.text)
                    .padding(.vertical)
            }
            Button {
                showPrivacyPolicy = true
            } label: {
                Text(message)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                TextWall(PrivacyPolicy.markdownContent)
            }
            Spacer()
        }
    }
    
    @ViewBuilder func TextWall(_ markdownContent: String) -> some View {
        ScrollView {
            Markdown(markdownContent)
                .markdownTextStyle { ForegroundColor(Color.text) }
                .frame(maxWidth: .infinity)
                .padding()
        }
        .background(Color.background)
        .presentationDragIndicator(.visible)
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
            .sheet(isPresented: .constant(true)) {
                EditUserProfileView(userId: "userId", mode: .editProfile)
            }
    }
}
