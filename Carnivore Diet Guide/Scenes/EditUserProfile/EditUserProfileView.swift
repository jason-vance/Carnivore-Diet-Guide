//
//  EditUserProfileView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/2/24.
//

import SwiftUI

struct EditUserProfileView: View {
    
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @State var profileImage: UIImage = .init()
    @State var usersFullName: PersonName? = nil
    @State var username: Username? = nil
    
    private func saveProfileData() {
        //TODO: Implement saveProfileData()
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
                            ProfileFormNameField($usersFullName)
                            ProfileFormUsernameField($username)
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
        .presentationDetents([.large])
        .toolbar(.visible, for: .navigationBar)
        .toolbarRole(.automatic)
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder func TitleBar() -> some View {
        Text("Edit Profile")
            .bold()
            .foregroundStyle(Color.accent)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .leading) {
                CancelButton()
            }
            .overlay(alignment: .trailing) {
                SaveButton()
            }
            .padding()
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
        }
    }
    
    @ViewBuilder func SaveButton() -> some View {
        Button {
            saveProfileData()
        } label: {
            Text("Save")
                .foregroundStyle(Color.background)
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        Rectangle()
            .popover(isPresented: .constant(true), content: {
                EditUserProfileView()
            })
    }
}
