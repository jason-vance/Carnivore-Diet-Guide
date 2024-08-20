//
//  CreatePostView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI
import YPImagePicker

struct CreatePostView: View {
    
    private let imageSize: CGFloat = 128
    
    private struct PostImage: Identifiable {
        let id = UUID()
        let image: UIImage
    }
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @StateObject private var model = CreatePostViewModel()
    
    @State private var postTitle: String = ""
    @State private var postImages: [PostImage] = []
    @State private var postText: String = ""
    
    @State private var showImagePicker: Bool = false
    
    private func close() {
        //TODO: dismiss if empty, show discard changes dialog if not
    }
    
    private func goToNext() {
        //TODO: Implement CreatePostView.goToNext()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            List {
                ImageCarouselField()
                PostTitleField()
                PostTextField()
            }
            .listStyle(.plain)
        }
        .background(Color.background)
    }
    
    @ViewBuilder func TopBar() -> some View {
        HStack {
            CloseButton()
            Spacer()
            NextButton()
        }
        .padding(.horizontal)
        .frame(height: .defaultBarHeight)
        .overlay(alignment: .bottom) { BarDivider() }
        
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            close()
        } label: {
            Image(systemName: "xmark")
                .bold()
        }
    }
    
    @ViewBuilder func NextButton() -> some View {
        Button {
            goToNext()
        } label: {
            Text("Next")
                .foregroundStyle(Color.background)
                .font(.caption.bold())
                .padding(8)
                .background() {
                    Capsule()
                        .foregroundStyle(Color.accent)
                }
        }
    }
    
    @ViewBuilder func ImageCarouselField() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(postImages) { image in
                    ImageCarouselItem(image)
                }
                AddImageButton()
            }
            .scrollTargetLayout()
            .padding(.vertical)
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .listRowInsets(EdgeInsets())    // Must be last or scrollContent margins will be messed up
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder private func ImageCarouselItem(_ image: PostImage) -> some View {
        Image(uiImage: image.image)
            .resizable()
            .scaledToFill()
            .frame(width: imageSize, height: imageSize)
            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            .id(image.id)
            .overlay {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(style: .init(lineWidth: 2))
                    .foregroundStyle(Color.accent)
            }
        //TODO: Add a way to remove images
    }
    
    @ViewBuilder private func AddImageButton() -> some View {
        Button {
            showImagePicker = true
        } label: {
            Image(systemName: "photo")
                .foregroundStyle(Color.accent)
                .frame(width: imageSize, height: imageSize)
                .overlay {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke(style: .init(lineWidth: 2))
                        .foregroundStyle(Color.accent)
                }
        }
        .sheet(isPresented: $showImagePicker, content: ImagePicker)
    }
    
    @ViewBuilder func PostTitleField() -> some View {
        TextField("Title", text: $postTitle, prompt: Text("Title"))
            .textInputAutocapitalization(.words)
            .font(.title.bold())
            .foregroundStyle(Color.text)
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
    }
    
    @ViewBuilder func PostTextField() -> some View {
        ZStack(alignment: .topLeading) {
            Text("Body Text")
                .foregroundStyle(Color.text)
                .opacity(0.3)
                .padding(.vertical, 8)
                .padding(.horizontal, 5)
                .opacity(postText.isEmpty ? 1 : 0)
            TextEditor(text: $postText)
                .textInputAutocapitalization(.sentences)
                .foregroundStyle(Color.text)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder func ImagePicker() -> some View {
        ImagePickerView { selectedImage in
            showImagePicker = false
            postImages.append(PostImage(image: selectedImage))
        } didCancel: {
            showImagePicker = false
        }
    }
}

#Preview {
    CreatePostView()
}
