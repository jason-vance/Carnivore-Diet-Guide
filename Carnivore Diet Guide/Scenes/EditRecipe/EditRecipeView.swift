//
//  EditRecipeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/22/24.
//

import SwiftUI

struct EditRecipeView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var recipeImage: UIImage = .init()
    @State private var recipeImageUrl: URL? = nil
    @State private var recipeTitle: String = ""
    @State private var cookingLevel: Recipe.DifficultyLevel = .unknown
    @State private var cookTimeMinutes: Int?
    @State private var servings: Int = 1
    @State private var summary: String = ""
    @State private var ingredients: [Recipe.Ingredient] = []
    @State private var cookingSteps: [Recipe.CookingStep] = []
    @State private var basicNutritionInfo: BasicNutritionInfo = .zero

    var body: some View {
        VStack(spacing: 0) {
            TitleBar()
            ScrollView {
                VStack {
                    IngredientList(ingredients: $ingredients)
                }
                .padding(.top, .scrollShroudHeight)
            }
            .overlay(alignment: .top) { ScrollViewShroud() }
        }
        .background(Color.background)
        .interactiveDismissDisabled()
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder func TitleBar() -> some View {
        Text(recipeImageUrl == nil ? "Create Recipe" : "Edit Recipe")
            .bold()
            .foregroundStyle(Color.text)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .leading) {
                CancelButton()
            }
            .padding()
    }
    
    @ViewBuilder func CancelButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .bold()
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        StatefulPreviewContainer(true) { showSheet in
            Button {
                showSheet.wrappedValue = true
            } label: {
                Text("Show Sheet")
            }
            .sheet(isPresented: showSheet) {
                EditRecipeView()
            }
        }
    }
}
