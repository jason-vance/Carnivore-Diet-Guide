//
//  CreateRecipeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/29/24.
//

import SwiftUI
import YPImagePicker
import SwinjectAutoregistration

struct CreateRecipeView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @StateObject private var model = CreateRecipeViewModel(
    )
    
    @Binding public var selectedContentType: Resource.ResourceType
    
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
        //TODO: Implement CreateRecipeView.goToNext()
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                TopBar()
                List {
                    //TODO: Fill out the CreateRecipeView form
                }
                .listStyle(.plain)
            }
            .background(Color.background)
            .confirmationDialog(
                "Do you want to discard your recipe?",
                isPresented: $showDiscardDialog,
                titleVisibility: .visible
            ) {
                DiscardButton()
                CancelButton()
            }
            .navigationDestination(for: ReviewRecipeData.self) { recipeData in
                //TODO: Navigate to next step of recipe creation
                Text("Recipe creation next step")
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
        ScreenTitleBar {
            TitleMenu()
        } leadingContent: {
            CloseButton()
        } trailingContent: {
            NextButton()
        }
    }
    
    @ViewBuilder func TitleMenu() -> some View {
        CreateContentView.TitleMenu(String(localized: "Create Recipe"), contentType: $selectedContentType)
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
                        .foregroundStyle(model.reviewRecipeData == nil ? Color.gray : Color.accent)
                }
        }
        .disabled(model.reviewRecipeData == nil)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CreateRecipeView(selectedContentType: .constant(.recipe))
    }
}
