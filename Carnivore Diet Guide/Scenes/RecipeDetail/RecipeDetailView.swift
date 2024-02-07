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
    
    var recipe: Recipe
    
    @State private var showExtraMenuOptions: Bool = false
    
    var body: some View {
        StickyHeaderScrollingView(
            headerContent: HeaderContent(progress:),
            headerBackground: HeaderBackground,
            scrollableContent: ScrollableContent
        )
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder func HeaderBackground() -> some View {
        Group {
            if let imageName = recipe.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            if let imageUrl = recipe.imageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .foregroundStyle(Color.background)
                    }
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
    
    @ViewBuilder func HeaderContent(progress: CGFloat) -> some View {
        RecipeDetailsHeaderContent()
    }
    
    @ViewBuilder func ScrollableContent() -> some View {
        VStack {
            MetadataLine()
            RecipeTitle()
            ServingsLine()
            ByLine()
            RecipeContentView()
            NutritionalInformation()
        }
        .padding()
    }
    
    @ViewBuilder func RecipeTitle() -> some View {
        Text(recipe.title)
            .font(.system(size: 32, weight: .black))
            .foregroundStyle(Color.text)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder func ByLine() -> some View {
        HStack {
            //TODO: Get a real profile pic
            ProfileImageView(URL(string:"https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg"), size: 44, padding: 2)
            VStack {
                Text(recipe.author)
                    .font(.system(size: 16, weight: .bold))
                    .opacity(0.8)
            }
            Spacer()
        }
        .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func ServingsLine() -> some View {
        HStack {
            Text("Yields: \(recipe.servings) servings")
                .font(.caption)
                .foregroundStyle(Color.text)
            Spacer()
        }
    }
    
    @ViewBuilder func MetadataLine() -> some View {
        HStack {
            DifficultyLevelMetadataItem()
            MetadataSeparator()
            CookTimeMetadataItem()
            Spacer()
            CommentsMetadataItem()
            MetadataSeparator()
            FavoritesMetadataItem()
        }
        .font(.caption)
        .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func MetadataSeparator() -> some View {
        Circle()
            .fill(Color.text)
            .frame(width: 4, height: 4)
    }
    
    @ViewBuilder func CookTimeMetadataItem() -> some View {
        //TODO: Get a real cook time
        MetadataItem(text: "17mins", icon: "clock")
    }
    
    @ViewBuilder func DifficultyLevelMetadataItem() -> some View {
        //TODO: Get a real cooking level
        MetadataItem(text: "easy", icon: "frying.pan")
    }
    
    @ViewBuilder func FavoritesMetadataItem() -> some View {
        //TODO: Get a real favorite count
        MetadataItem(text: "345", icon: "heart")
    }
    
    @ViewBuilder func CommentsMetadataItem() -> some View {
        //TODO: Get a real comment count
        MetadataItem(text: "345", icon: "text.bubble")
    }
    
    @ViewBuilder func MetadataItem(text: String, icon: String? = nil) -> some View {
        HStack(spacing: 2) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(text)
        }
    }
    
    @ViewBuilder func RecipeContentView() -> some View {
        Markdown(recipe.markdownContent)
            .markdownTextStyle {
                ForegroundColor(Color.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
    }
    
    @ViewBuilder func NutritionalInformation() -> some View {
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
                RoundedRectangle(cornerRadius: Corners.radius)
                    .stroke(Color.text, lineWidth: 1)
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
    NavigationStack {
        NavigationLink {
            RecipeDetailView(recipe: .longNamedSample)
        } label: {
            Text("Recipe Details")
        }
    }
    
}
