//
//  RecipeDetailView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import SwiftUI
import Kingfisher
import MarkdownUI

struct RecipeDetailView: View {
    
    private let imageHeight: CGFloat = 200

    @State var recipeId: String
    @StateObject private var model = RecipeDetailViewModel()
    @State private var showExtraMenuOptions: Bool = false
    
    var body: some View {
        StickyHeaderScrollingView(
            headerContent: HeaderContent(progress:),
            headerBackground: HeaderBackground,
            scrollableContent: ScrollableContent
        )
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .onChange(of: recipeId, initial: true) { newRecipeId in
            model.set(recipeId: newRecipeId)
        }
    }
    
    @ViewBuilder func HeaderBackground() -> some View {
        if let imageName = model.recipe?.imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let imageUrl = model.recipe?.imageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .placeholder {
                    Rectangle()
                        .foregroundStyle(Color.background)
                }
                .aspectRatio(contentMode: .fill)
        } else {
            Color.text
        }
    }
    
    @ViewBuilder func HeaderContent(progress: CGFloat) -> some View {
        RecipeDetailsHeaderContent(recipe: model.recipe)
            .id(model.recipe?.id ?? UUID().uuidString)
    }
    
    @ViewBuilder func ScrollableContent() -> some View {
        if let recipe = model.recipe {
            VStack {
                RecipeDetailMetadataView(recipe: recipe)
                RecipeTitle(recipe)
                ServingsLine(recipe)
                ByLineView(userId: recipe.authorUserId)
                RecipeContentView(recipe)
                NutritionalInformation(recipe)
            }
            .padding()
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.accent)
                .padding(.vertical, 128)
        }
    }
    
    @ViewBuilder func RecipeTitle(_ recipe: Recipe) -> some View {
        Text(recipe.title)
            .font(.system(size: 32, weight: .black))
            .foregroundStyle(Color.text)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder func ServingsLine(_ recipe: Recipe) -> some View {
        HStack {
            Text("Yields: \(recipe.servings) servings")
                .font(.caption)
                .foregroundStyle(Color.text)
            Spacer()
        }
    }
    
    @ViewBuilder func RecipeContentView(_ recipe: Recipe) -> some View {
        Markdown(recipe.markdownContent)
            .markdownTextStyle {
                ForegroundColor(Color.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
    }
    
    @ViewBuilder func NutritionalInformation(_ recipe: Recipe) -> some View {
        if let basicNutritionInfo = recipe.basicNutritionInfo {
            VStack(spacing: 12) {
                Text("Nutritional Info")
                    .font(.system(size: 24, weight: .bold))
                Text("Per Serving")
                NutritionInformationItem(
                    String(localized: "Calories"),
                    value: "\(basicNutritionInfo.calories)",
                    unit: String(localized: "kcal")
                )
                Rectangle().frame(height: 2)
                NutritionInformationItem(
                    String(localized: "Protein"),
                    value: "\(basicNutritionInfo.protein)",
                    unit: String(localized: "g", comment: "grams")
                )
                Rectangle().frame(height: 1)
                NutritionInformationItem(
                    String(localized: "Fat"),
                    value: "\(basicNutritionInfo.fat)",
                    unit: String(localized: "g", comment: "grams")
                )
                Rectangle().frame(height: 1)
                NutritionInformationItem(
                    String(localized: "Carbohydrates"),
                    value: "\(basicNutritionInfo.carbohydrates)",
                    unit: String(localized: "g", comment: "grams")
                )
            }
            .foregroundStyle(Color.text)
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                    .stroke(Color.text, lineWidth: .borderWidthThin)
            }
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
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        NavigationStack {
            NavigationLink {
                RecipeDetailView(recipeId: Recipe.sample.id)
            } label: {
                Text("Recipe Details")
            }
        }
    }
}
