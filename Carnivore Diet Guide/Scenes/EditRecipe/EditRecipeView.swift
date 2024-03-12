//
//  EditRecipeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/22/24.
//

import SwiftUI

struct EditRecipeView: View {
    
    private let sampleMarkdown: String = """
This field supports Markdown.

Tap the binoculars button to see what this will look like when it is displayed.

## Ingredients
- Something Tasty
- Something Yummy

## Cooking Steps
1. **Gather:** Put all the ingredients into a bowl
2. **Mix:** Stir the ingredients together
"""
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var resourceImage: UIImage = .init()
    @State private var resourceImageUrl: URL? = nil
    @State private var resourceTitle: String = ""
    @State private var difficultyLevel: Recipe.DifficultyLevel = .easy
    @State private var cookTime: GreaterThanZeroMicrowaveTime = .default
    @State private var servings: GreaterThanZeroInt = .one
    @State private var summary: String = ""
    @State private var markdownContent: String = ""
    @State private var basicNutritionInfo: BasicNutritionInfo = .zero
    
    @State private var isDifficultyLevelDialogPresented: Bool = false
    @State private var isCookingTimeDialogPresented: Bool = false
    @State private var isServingsDialogPresented: Bool = false
    @State private var isNutritionInfoDialogPresented: Bool = false
    
    private var formData: EditRecipeFormData? {
        guard let resourceImageUrl = resourceImageUrl else { return nil }
        guard let resourceTitle = try? ResourceTitle(resourceTitle) else { return nil }
        guard let summary = try? ResourceSummary(summary) else { return nil }
        guard let markdownContent = try? ResourceMarkdownContent(markdownContent) else { return nil }

        return EditRecipeFormData(
            resourceImageUrl: resourceImageUrl,
            resourceTitle: resourceTitle,
            difficultyLevel: difficultyLevel,
            cookTime: cookTime,
            servings: servings,
            summary: summary,
            markdownContent: markdownContent,
            basicNutritionInfo: basicNutritionInfo
        )
    }

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
                    NutritionInfoField()
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
                .foregroundStyle(Color.text)
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
            prompt: String(localized: "ex. Seared Ribeye Steak"),
            hasError: (try? ResourceTitle(resourceTitle)) == nil,
            autoCapitalization: .words,
            errorContent: { Text("Title cannot be empty") }
            //TODO: Get error description from ResourceTitle
        )
    }
    
    @ViewBuilder func CookingLevelField() -> some View {
        FormDialogField(
            label: String(localized: "Difficulty Level"),
            isDialogPresented: $isDifficultyLevelDialogPresented,
            hasError: difficultyLevel == .unknown) {
                Text(difficultyLevel.uiString)
            } errorContent: {
                Text("Providing a cooking level is required")
            }
            .sheet(isPresented: $isDifficultyLevelDialogPresented) {
                RecipeDifficultyLevelDialog(difficultyLevel: $difficultyLevel)
            }
    }
    
    @ViewBuilder func CookingTimeField() -> some View {
        FormDialogField(
            label: String(localized: "Cooking Time"),
            isDialogPresented: $isCookingTimeDialogPresented,
            hasError: false) {
                Text(cookTime.formatted())
            } errorContent: {
                Text("Cooking time must be greater than zero")
            }
            .sheet(isPresented: $isCookingTimeDialogPresented) {
                MicrowaveTimeEntryDialog(
                    prompt: String(localized: "Cooking Time"),
                    microwaveTime: .init(
                        get: { cookTime.value },
                        set: {
                            guard let newValue = try? GreaterThanZeroMicrowaveTime($0) else {
                                cookTime = .default
                                return
                            }
                            cookTime = newValue
                        }
                    )
                )
            }
    }
    
    @ViewBuilder func ServingsField() -> some View {
        FormDialogField(
            label: String(localized: "Servings"),
            isDialogPresented: $isServingsDialogPresented,
            hasError: false) {
                Text("\(servings.value)")
            } errorContent: {
                Text("Servings must be greater than 0")
            }
            .sheet(isPresented: $isServingsDialogPresented) {
                NumberEntryDialogView(
                    prompt: String(localized: "Servings", comment: "The amount of servings a recipe has"),
                    number: .init(
                        get: { servings.value },
                        set: {
                            guard let newValue = $0 else {
                                servings = .one
                                return
                            }
                            guard let newServings = try? GreaterThanZeroInt(newValue) else {
                                servings = .one
                                return
                            }
                            servings = newServings
                        }
                    )
                )
            }
    }
    
    @ViewBuilder func SummaryField() -> some View {
        FormLongTextField(
            text: $summary,
            label: String(localized: "Summary"),
            prompt: String(localized: "Tell us a bit about your recipe"),
            hasError: (try? ResourceSummary(summary)) == nil,
            errorContent: { Text("Summary must not be empty") }
            //TODO: Get error description from ResourceSummary
        )
    }
    
    @ViewBuilder func MarkdownContentField() -> some View {
        FormMarkdownContentField(
            markdownContent: $markdownContent,
            label: String(localized: "Recipe"),
            prompt: "",
            sampleMarkdown: sampleMarkdown,
            hasError: (try? ResourceMarkdownContent(markdownContent)) == nil,
            errorContent: { Text("Recipe must not be empty") }
            //TODO: Get error description from ResourceMarkdownContent
        )
    }
    
    @ViewBuilder func NutritionInfoField() -> some View {
        FormDialogField(
            label: String(localized: "Nutrition Info"),
            isDialogPresented: $isNutritionInfoDialogPresented,
            hasError: false,
            valueContent: {
                Text(basicNutritionInfo.calories > 0 ? "\(basicNutritionInfo.calories) Cals" : "--")
            },
            errorContent: { Text("Providing nutrition info is optional") }
        )
        .sheet(isPresented: $isNutritionInfoDialogPresented) {
            BasicNutritionInfoEntryDialog(nutritionInfo: $basicNutritionInfo)
        }
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
