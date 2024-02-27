//
//  ResourceFormImageField.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/26/24.
//

import SwiftUI
import Kingfisher

struct ResourceFormImageField: View {
    
    @Binding var resourceImage: UIImage
    var resourceImageUrl: URL?
    var resourceImageSize: CGFloat
    
    @State private var showImagePicker: Bool = false
    
    private var padding: CGFloat { .buttonStrokeWidthDefault }
    private var noUrlImageSize: CGFloat { resourceImageSize - (2 * padding) }
    
    var body: some View {
        Button {
            showImagePicker = true
        } label: {
            ZStack(alignment: .bottomTrailing) {
                ResourceImageContainer()
                ResourceImageIconOverlay()
            }
        }
        .fullScreenCover(isPresented: $showImagePicker, content: ImagePicker)
    }
    
    @ViewBuilder func ResourceImageContainer() -> some View {
        if resourceImage != .init() {
            Image(uiImage: resourceImage)
                .resizable()
                .scaledToFill()
                .frame(width: noUrlImageSize, height: noUrlImageSize)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous))
                .padding(padding)
                .background(RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous).fill(Color.text))
        } else if resourceImageUrl != nil {
            KFImage(resourceImageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: noUrlImageSize, height: noUrlImageSize)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous))
                .padding(padding)
                .background(RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous).fill(Color.text))
        } else {
            ZStack {
                RoundedRectangle(
                    cornerRadius: .cornerRadiusDefault,
                    style: .continuous
                )
                .stroke(lineWidth: .buttonStrokeWidthDefault)
                .foregroundStyle(Color.accent)
                Image(systemName: "photo")
                    .font(.system(size: noUrlImageSize / 2))
                    .foregroundStyle(Color.text.opacity(0.2))
            }
            .frame(width: resourceImageSize, height: resourceImageSize)
        }
    }
    
    @ViewBuilder func ResourceImageIconOverlay() -> some View {
        Image(systemName: "camera.circle.fill")
            .resizable()
            .frame(width: 48, height: 48)
            .padding(4)
            .background {
                Circle()
                    .foregroundStyle(Color.text)
            }
            .padding(.paddingMedium)
    }
    
    @ViewBuilder func ImagePicker() -> some View {
        ImagePickerView { selectedImage in
            showImagePicker = false
            resourceImage = selectedImage
        } didCancel: {
            showImagePicker = false
        }
    }
}

#Preview("With Image Url") {
    StatefulPreviewContainer(UIImage()) { image in
        GeometryReader { proxy in
            ResourceFormImageField(
                resourceImage: image,
                resourceImageUrl: UserData.sample.profileImageUrl,
                resourceImageSize: proxy.size.width
            )
        }
    }
}

#Preview("Without Image Url") {
    StatefulPreviewContainer(UIImage()) { image in
        GeometryReader { proxy in
            ResourceFormImageField(
                resourceImage: image,
                resourceImageUrl: nil,
                resourceImageSize: proxy.size.width
            )
        }
    }
}
