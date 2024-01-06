//
//  RecipeDetailView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/4/24.
//

import SwiftUI

struct RecipeDetailView: View {
    
    var recipe: Recipe
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    var body: some View {
        VStack {
            RecipeImage()
            VStack(spacing: 0) {
                RecipeTitle()
                ScrollView {
                    VStack {
                        IngredientList()
                        CookingSteps()
                        NutritionalInformation()
                    }
                }
            }
            .background(Color.background)
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        }
        .background(Color.background)
    }
    
    @ViewBuilder func RecipeImage() -> some View {
        Image(recipe.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 200)
            .overlay(alignment: .bottomLeading) {
                CloseButton()
                    .padding()
            }
    }
    
    @ViewBuilder func RecipeTitle() -> some View {
        Text(recipe.title)
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(Color.background)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.text)
    }
    
    @ViewBuilder func IngredientList() -> some View {
        VStack(alignment: .leading) {
            SectionTitleView("Ingredients:")
            ForEach(recipe.ingredients, id: \.self) { ingredient in
                Text(ingredient)
            }
        }
    }
    
    @ViewBuilder func CookingSteps() -> some View {
        VStack(alignment: .leading) {
            Text("Cooking Steps:")
                .font(.headline)
            
            ForEach(recipe.cookingSteps.indices, id: \.self) { index in
                Text("\(index + 1). \(recipe.cookingSteps[index])")
            }
        }
    }
    
    @ViewBuilder func NutritionalInformation() -> some View {
        VStack(alignment: .leading) {
            Text("Nutritional Information:")
                .font(.headline)
            
            Text("Calories: \(recipe.calories) kcal")
            Text("Protein: \(recipe.protein) g")
            Text("Carbohydrates: \(recipe.carbohydrates) g")
            Text("Fat: \(recipe.fat) g")
        }
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(Color.accent)
                    .frame(width: 32, height: 32)
                Image(systemName: "xmark")
                    .resizable()
                    .bold()
                    .foregroundStyle(Color.background)
                    .frame(width: 16, height: 16)
            }
        }
    }
    
    @ViewBuilder func SectionTitleView(
        _ text: String,
        theme: UIUserInterfaceStyle = .dark
    ) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(theme == .light ? Color.text : Color.background)
            Spacer()
        }
        .padding()
        .background(theme == .light ? Color.background : Color.text)
    }}

#Preview {
    RecipeDetailView(recipe: Recipe(
            title: "Seared Ribeye Steak",
            imageName: "SearedRibeyeSteak",
            ingredients: ["500g spaghetti", "400g ground beef", "1 onion", "1 can of tomato sauce", "1 clove of garlic", "Salt and pepper to taste"],
            cookingSteps: ["Boil spaghetti until al dente.", "Brown ground beef with onions and garlic.", "Add tomato sauce and season with salt and pepper.", "Serve sauce over cooked spaghetti."],
            calories: 300,
            protein: 10,
            carbohydrates: 40,
            fat: 12
        )
    )
}
