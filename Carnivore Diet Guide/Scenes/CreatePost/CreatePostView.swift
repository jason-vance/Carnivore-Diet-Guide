//
//  CreatePostView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI
import YPImagePicker
import SwinjectAutoregistration

//TODO: CreateArticleContentView (title, coverImage, markdownContent)
//TODO: CreateArticleMetadataView (summary, tags, categories)
//TODO: ReviewArticleView (prominent, tall, wide ArticleItemViews, and content)

struct CreatePostView: View {
    
    private let imageSize: CGFloat = 128
    private let imageCornerRadius: CGFloat = 12
    private let imageBorderWidth: CGFloat = 2
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @StateObject private var model = CreatePostViewModel(
        userIdProvider: iocContainer~>CurrentUserIdProvider.self,
        imageUploader: iocContainer~>PostImageUploader.self
    )
    
    @State private var navigationPath = NavigationPath()
    @State private var showImagePicker: Bool = false
    @State private var showDiscardDialog: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    private func close() {
        if model.isFormEmpty {
            dismiss()
        } else {
            showDiscardDialog = true
        }
    }
    
    private func goToNext() {
        guard let postData = model.reviewPostData else {
            show(alertMessage: "Could not create ReviewPostData")
            return
        }
        navigationPath.append(postData)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
            .confirmationDialog(
                "Do you want to discard your post?",
                isPresented: $showDiscardDialog,
                titleVisibility: .visible
            ) {
                DiscardButton()
                CancelButton()
            }
            .navigationDestination(for: ReviewPostData.self) { postData in
                ReviewNewPostView(postData: postData) { dismiss() }
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {}
    }
    
    @ViewBuilder func DiscardButton() -> some View {
        Button("Discard", role: .destructive) {
            model.deleteImagesUnsafely()
            dismiss()
        }
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button("Cancel", role: .cancel) { }
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
                        .foregroundStyle(model.reviewPostData == nil ? Color.gray : Color.accent)
                }
        }
        .disabled(model.reviewPostData == nil)
    }
    
    @ViewBuilder func ImageCarouselField() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(model.postImages) { image in
                    ImageCarouselItem(image)
                }
                if model.canAddImages {
                    AddImageButton()
                }
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
    
    @ViewBuilder private func ImageCarouselItem(_ image: CreatePostImageData) -> some View {
        Image(uiImage: image.image)
            .resizable()
            .scaledToFill()
            .frame(width: imageSize, height: imageSize)
            .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous))
            .opacity(image.url == nil ? 0.8 : 1)
            .shimmering(isActive: image.url == nil)
            .id(image.id)
            .overlay {
                RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous)
                    .stroke(style: .init(lineWidth: imageBorderWidth))
                    .foregroundStyle(Color.accent)
            }
            .overlay(alignment: .bottomTrailing) {
                if image.url != nil {
                    RemoveImageButton(image)
                }
            }
    }
    
    @ViewBuilder private func RemoveImageButton(_ image: CreatePostImageData) -> some View {
        Button {
            model.removeFromPost(image: image)
        } label: {
            ImageAccessory("minus")
        }
    }
    
    @ViewBuilder private func AddImageButton() -> some View {
        Button {
            showImagePicker = true
        } label: {
            Image(systemName: "photo")
                .foregroundStyle(Color.accent)
                .frame(width: imageSize, height: imageSize)
                .background {
                    RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous)
                        .foregroundStyle(Color.background)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous)
                        .stroke(style: .init(lineWidth: imageBorderWidth))
                        .foregroundStyle(Color.accent)
                }
                .overlay(alignment: .bottomTrailing) {
                    ImageAccessory("plus")
                }
        }
        .sheet(isPresented: $showImagePicker, content: ImagePicker)
    }
    
    @ViewBuilder private func ImageAccessory(_ name: String) -> some View {
        Image(systemName: name)
            .foregroundStyle(Color.background)
            .frame(width: imageCornerRadius * 3, height: imageCornerRadius * 2)
            .background {
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: imageCornerRadius, bottomTrailing: imageCornerRadius),
                    style: .continuous
                )
                .foregroundStyle(Color.accent)
            }
    }
    
    @ViewBuilder func PostTitleField() -> some View {
        TextField(
            "Title",
            text: $model.postTitle,
            prompt: Text("Title").foregroundStyle(Color.text.opacity(0.3))
        )
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
                .opacity(model.postText.isEmpty ? 1 : 0)
            TextEditor(text: $model.postText)
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
            model.addToPost(image: selectedImage)
        } didCancel: {
            showImagePicker = false
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CreatePostView()
    }
}
