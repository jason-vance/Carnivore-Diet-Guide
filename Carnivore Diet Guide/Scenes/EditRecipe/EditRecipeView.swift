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
    
    //TODO: Is there a way to turn these resource image fields into a ValueOf?
    @State private var resourceImage: UIImage = .init()
    @State private var resourceImageUrl: URL? = nil
    @State private var resourceTitle: NonEmptyString?
    @State private var difficultyLevel: Recipe.DifficultyLevel = .unknown
    @State private var cookTime: GreaterThanZeroMicrowaveTime = .default
    @State private var servings: GreaterThanZeroInt = .one
    @State private var summary: NonEmptyString?
    @State private var markdownContent: NonEmptyString?
    @State private var basicNutritionInfo: BasicNutritionInfo = .zero
    //TODO: I Probably want to make a small library of components that I like to use in my apps
    // IE. StickyHeaderScrollingView, MicrowaveTimeEntryDialog, TaskAwareButton, etc
    
    @State private var isDifficultyLevelDialogPresented: Bool = false
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
            text: .init(
                get: { resourceTitle?.value ?? "" },
                set: {
                    guard let newValue = NonEmptyString($0) else {
                        resourceTitle = nil
                        return
                    }
                    resourceTitle = newValue
                }
            ),
            label: String(localized: "Title"),
            prompt: String(localized: "ex. Seared Ribeye Steak"),
            hasError: resourceTitle == nil,
            autoCapitalization: .words,
            errorContent: { Text("Title cannot be empty") }
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
                            guard let newValue = GreaterThanZeroMicrowaveTime($0) else {
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
                            guard let newServings = GreaterThanZeroInt(newValue) else {
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
            text: .init(
                get: { summary?.value ?? "" },
                set: {
                    guard let newValue = NonEmptyString($0) else {
                        summary = nil
                        return
                    }
                    summary = newValue
                }
            ),
            label: String(localized: "Summary"),
            prompt: String(localized: "Tell us about your recipe"),
            hasError: summary == nil,
            errorContent: { Text("Summary must not be empty") }
        )
    }
    
    @ViewBuilder func MarkdownContentField() -> some View {
        FormMarkdownContentField(
            markdownContent: .init(
                get: { markdownContent?.value ?? "" },
                set: {
                    guard let newValue = NonEmptyString($0) else {
                        markdownContent = nil
                        return
                    }
                    markdownContent = newValue
                }
            ),
            label: String(localized: "Recipe"),
            prompt: "",
            sampleMarkdown: sampleMarkdown,
            hasError: markdownContent == nil,
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
