//
//  EditRecipeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/22/24.
//

import SwiftUI

struct EditRecipeView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var resourceImage: UIImage = .init()
    @State private var resourceImageUrl: URL? = nil
    @State private var resourceTitle: String = ""
    @State private var cookingLevel: Recipe.DifficultyLevel = .unknown
    @State private var cookTimeMinutes: Int?
    @State private var servings: Int? = 1
    @State private var summary: String = ""
    @State private var markdownContent: String = ""
    @State private var basicNutritionInfo: BasicNutritionInfo = .zero
    //TODO: I probably need to make a bunch of ValueOf type classes to hold all of this data
    
    @State private var isCookingLevelDialogPresented: Bool = false
    @State private var isCookingTimeDialogPresented: Bool = false
    @State private var isServingsDialogPresented: Bool = false

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: .paddingDefault) {
                    ImageField(screenWidth: geo.size.width)
                    TitleField()
                    CookingLevelField()
                    CookingTimeField()
                    ServingsField()
                    SummaryField()
                    MarkdownContentField()
                    //TODO: Add a field for basicNutritionInfo
                }
                .padding(.paddingDefault)
            }
        }
        .background(Color.background)
        .interactiveDismissDisabled()
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { Toolbar() }
        .toolbarBackground(.ultraThinMaterial)
    }
    
    @ToolbarContentBuilder func Toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Create Recipe")
                .font(.subHeaderBold)
        }
        ToolbarItem(placement: .topBarLeading) {
            CancelButton()
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
    
    @ViewBuilder func ImageField(screenWidth: CGFloat) -> some View {
        ResourceFormImageField(
            resourceImage: $resourceImage,
            resourceImageUrl: resourceImageUrl,
            resourceImageSize: screenWidth - (2 * .paddingDefault)
        )
    }
    
    @ViewBuilder func TitleField() -> some View {
        FormTextField(
            text: $resourceTitle,
            label: String(localized: "Title"),
            prompt: String(localized: "Seared Ribeye Steak"),
            hasError: resourceTitle.isEmpty,
            autoCapitalization: .words,
            errorContent: TitleErrorView
        )
    }
    
    @ViewBuilder func TitleErrorView() -> some View {
        Text("Title cannot be empty")
    }
    
    @ViewBuilder func CookingLevelField() -> some View {
        FormDialogField(
            label: String(localized: "Cooking Level"),
            isDialogPresented: $isCookingLevelDialogPresented,
            hasError: cookingLevel == .unknown) {
                Text(cookingLevel.uiString)
            } errorContent: {
                Text("Providing a cooking level is required")
            }
        //TODO: Show a cooking level dialog
    }
    
    @ViewBuilder func CookingTimeField() -> some View {
        FormDialogField(
            label: String(localized: "Cooking Time"),
            isDialogPresented: $isCookingTimeDialogPresented,
            hasError: cookTimeMinutes == nil) {
                Text(cookTimeMinutes?.formatted() ?? "--:--")
            } errorContent: {
                Text("Providing a cooking time is required")
            }
        //TODO: Show a cooking time dialog
    }
    
    @ViewBuilder func ServingsField() -> some View {
        FormDialogField(
            label: String(localized: "Servings"),
            isDialogPresented: $isServingsDialogPresented,
            hasError: servings == nil || servings! <= 0) {
                Text(servings == nil ? "--" : "\(servings!)")
            } errorContent: {
                Text("Servings must be greater than 0")
            }
            .sheet(isPresented: $isServingsDialogPresented) {
                NumberEntryDialogView(
                    prompt: String(localized: "Servings", comment: "The amount of servings a recipe has"),
                    number: $servings
                )
            }
    }
    
    @ViewBuilder func SummaryField() -> some View {
        FormLongTextField(
            text: $summary,
            label: String(localized: "Summary"),
            prompt: String(localized: "Tell us about your recipe"),
            hasError: summary.isEmpty,
            errorContent: { Text("Summary must not be empty") }
        )
    }
    
    @ViewBuilder func MarkdownContentField() -> some View {
        FormMarkdownContentField(
            markdownContent: $markdownContent,
            label: String(localized: "Recipe"),
            prompt: "",
            hasError: markdownContent.isEmpty,
            errorContent: { Text("Recipe must not be empty") }
        )
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        StatefulPreviewContainer(true) { showSheet in
            NavigationStack {
                EditRecipeView()
            }
        }
    }
}
