//
//  RecipeDetailView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/4/24.
//

import SwiftUI

struct RecipeDetailView: View {
    
    private static let ingredientsTab = TabSelectorView.Tab(title: "Ingredients")
    private static let stepsTab = TabSelectorView.Tab(title: "Cooking Steps")
    private static let nutritionTab = TabSelectorView.Tab(title: "Nutritional Info")
    
    var recipe: Recipe
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var selectedTab: TabSelectorView.Tab = ingredientsTab

    var body: some View {
        VStack {
            RecipeImage()
            VStack(spacing: 0) {
                RecipeTitle()
                TabSelectorView(
                    tabs: [Self.ingredientsTab, Self.stepsTab, Self.nutritionTab],
                    selectedTab: $selectedTab
                )
                RecipeContentView()
            }
            .background(Color.text)
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder func RecipeImage() -> some View {
        Image(recipe.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 200)
            .overlay(alignment: .bottomLeading) {
                CloseButton()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
    }
    
    @ViewBuilder func RecipeTitle() -> some View {
        VStack {
            Text(recipe.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.background)
            Text("Serves \(recipe.basicNutritionInfo.servings)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.darkAccentText)
        }
        .frame(maxWidth: .infinity)
        .background(Color.text)
        .padding()
    }
    
    @ViewBuilder func RecipeContentView() -> some View {
        ScrollView {
            VStack {
                switch selectedTab {
                case Self.ingredientsTab:
                    IngredientList()
                case Self.stepsTab:
                    CookingSteps()
                case Self.nutritionTab:
                    NutritionalInformation()
                default:
                    Text("")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.text)
        }
        .background(Color.background)
    }
    
    @ViewBuilder func IngredientList() -> some View {
        VStack() {
            ForEach(recipe.ingredients, id: \.self) { ingredient in
                HStack {
                    Circle()
                        .frame(width: 8, height: 8)
                    Text(ingredient)
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder func CookingSteps() -> some View {
        VStack(spacing: 12) {
            ForEach(recipe.cookingSteps.indices, id: \.self) { index in
                HStack(alignment: .top) {
                    Text("\(index + 1).")
                    Text(recipe.cookingSteps[index])
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder func NutritionalInformation() -> some View {
        VStack(spacing: 12) {
            Text("Per Serving")
            NutritionInformationItem(
                "Calories",
                value: "\(recipe.basicNutritionInfo.calories)",
                unit: "kcal"
            )
            Rectangle().frame(height: 2)
            NutritionInformationItem(
                "Protein",
                value: "\(recipe.basicNutritionInfo.protein)",
                unit: "g"
            )
            Rectangle().frame(height: 1)
            NutritionInformationItem(
                "Fat",
                value: "\(recipe.basicNutritionInfo.fat)",
                unit: "g"
            )
            Rectangle().frame(height: 1)
            NutritionInformationItem(
                "Carbohydrates",
                value: "\(recipe.basicNutritionInfo.carbohydrates)",
                unit: "g"
            )
        }
    }
    
    @ViewBuilder func NutritionInformationItem(_ name: String, value: String, unit: String) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text(name)
                .font(.system(size: 18, weight: .semibold))
            Spacer()
            Text(value)
                .font(.system(size: 18))
            Text(unit)
                .font(.system(size: 12, weight: .bold))
        }
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(Color.accent)
                    .frame(width: 44, height: 44)
                Image(systemName: "chevron.left")
                    .resizable()
                    .bold()
                    .foregroundStyle(Color.background)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
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
    RecipeDetailView(recipe: .sample)
}
