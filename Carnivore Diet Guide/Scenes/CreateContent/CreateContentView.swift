//
//  CreateContentView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI
import YPImagePicker
import SwinjectAutoregistration

struct CreateContentView: View {
    
    private let imageSize: CGFloat = 128
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @StateObject private var model = CreateContentViewModel(
        userIdProvider: iocContainer~>CurrentUserIdProvider.self,
        imageUploader: iocContainer~>PostImageUploader.self
    )

    @State private var navigationPath = NavigationPath()
    @State private var showImagePicker: Bool = false
    @State private var showDiscardDialog: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var screenTitle: String {
        switch model.contentType {
        case .article :
            String(localized: "Create Article")
        case .post :
            String(localized: "Create Post")
        case .recipe :
            String(localized: "Create Recipe")
        }
    }
    
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
        guard let postData = model.contentData else {
            show(alertMessage: "Could not create ContentData")
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
            .navigationDestination(for: ContentData.self) { contentData in
                NextCreationStepView(data: contentData)
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {}
    }
    
    @ViewBuilder func NextCreationStepView(data: ContentData) -> some View {
        switch model.contentType {
        case .post:
            ReviewNewPostView(postData: data) { dismiss() }
        case .recipe:
            //TODO: Navigate to the next correct recipe creation step
            Text(data.title)
        case .article:
            CreateArticleMetadataView(
                contentData: data,
                navigationPath: $navigationPath
            )
        }
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
        ScreenTitleBar {
            TitleMenu()
        } leadingContent: {
            CloseButton()
        } trailingContent: {
            GoToNextButton()
        }
    }
    
    @ViewBuilder func TitleMenu() -> some View {
        //TODO: Disable this for everyone except me
        Menu {
            Button {
                model.contentType = .article
            } label: {
                LabeledContent("Article") {
                    if model.contentType == .article {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button {
                model.contentType = .post
            } label: {
                LabeledContent("Post") {
                    if model.contentType == .post {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button {
                model.contentType = .recipe
            } label: {
                LabeledContent("Recipe") {
                    if model.contentType == .recipe {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            HStack {
                Text(screenTitle)
                ResourceMenuButtonLabel(sfSymbol: "chevron.down")
            }
        }
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            close()
        } label: {
            Image(systemName: "xmark")
                .bold()
        }
    }
    
    @ViewBuilder func GoToNextButton() -> some View {
        NextButton {
            goToNext()
        }
        .disabled(model.contentData == nil)
    }
    
    @ViewBuilder func ImageCarouselField() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(model.contentImages) { image in
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
    
    @ViewBuilder private func ImageCarouselItem(_ image: ContentCreationImageData) -> some View {
        Image(uiImage: image.image)
            .resizable()
            .scaledToFill()
            .frame(width: imageSize, height: imageSize)
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous))
            .opacity(image.url == nil ? 0.8 : 1)
            .shimmering(isActive: image.url == nil)
            .id(image.id)
            .overlay {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .stroke(style: .init(lineWidth: .borderWidthMedium))
                    .foregroundStyle(Color.accent)
            }
            .overlay(alignment: .bottomTrailing) {
                if image.url != nil {
                    RemoveImageButton(image)
                }
            }
    }
    
    @ViewBuilder private func RemoveImageButton(_ image: ContentCreationImageData) -> some View {
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
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .foregroundStyle(Color.background)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .stroke(style: .init(lineWidth: .borderWidthMedium))
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
            .frame(width: .cornerRadiusMedium * 3, height: .cornerRadiusMedium * 2)
            .background {
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: .cornerRadiusMedium, bottomTrailing: .cornerRadiusMedium),
                    style: .continuous
                )
                .foregroundStyle(Color.accent)
            }
    }
    
    @ViewBuilder func PostTitleField() -> some View {
        TextField(
            "Title",
            text: $model.contentTitle,
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
                .opacity(model.contentText.isEmpty ? 1 : 0)
            TextEditor(text: $model.contentText)
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
        CreateContentView()
    }
}
