//
//  ProfileFormPictureField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import SwiftUI

struct ProfileFormPictureField: View {
    
    @Binding var profileImage: UIImage
    var profileImageSize: CGFloat = 200
    var profileImageUrl: URL?
    
    @State private var showImagePicker: Bool = false

    var body: some View {
        Button {
            showImagePicker = true
        } label: {
            ZStack(alignment: .bottomTrailing) {
                ProfileImageContainer()
                ProfileImageIconOverlay()
            }
        }
        .fullScreenCover(isPresented: $showImagePicker, content: ImagePicker)
    }
    
    @ViewBuilder func ProfileImageContainer() -> some View {
        if profileImage != .init() {
            Image(uiImage: profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: profileImageSize, height: profileImageSize)
                .clipShape(Circle())
                .padding(4)
                .background(Circle().fill(Color.text))
        } else if profileImageUrl != nil {
            ProfileImageView(
                profileImageUrl,
                size: profileImageSize
            )
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: profileImageSize, height: profileImageSize)
                .clipShape(Circle())
                .padding(4)
                .background(Circle().fill(Color.text))
        }
    }
    
    @ViewBuilder func ProfileImageIconOverlay() -> some View {
        Image(systemName: "camera.circle.fill")
            .resizable()
            .frame(width: 48, height: 48)
            .padding(4)
            .background {
                Circle()
                    .foregroundStyle(Color.text)
            }
    }
    
    @ViewBuilder func ImagePicker() -> some View {
        ImagePickerView { selectedImage in
            showImagePicker = false
            profileImage = selectedImage
        } didCancel: {
            showImagePicker = false
        }
    }
}

#Preview("With Image Url") {
    StatefulPreviewContainer(UIImage()) { image in
        ProfileFormPictureField(
            profileImage: image,
            profileImageSize: 200,
            profileImageUrl: UserData.sample.profileImageUrl
        )
    }
}

#Preview("Without Image Url") {
    StatefulPreviewContainer(UIImage()) { image in
        ProfileFormPictureField(
            profileImage: image,
            profileImageSize: 200
        )
    }
}
