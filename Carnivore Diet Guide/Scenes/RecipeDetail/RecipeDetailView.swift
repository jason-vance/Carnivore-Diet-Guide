//
//  RecipeDetailView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/4/24.
//

import SwiftUI
import Kingfisher
import MarkdownUI

struct RecipeDetailView: View {
    
    let imageHeight: CGFloat = 200
    
    var recipe: Recipe
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    var body: some View {
        VStack {
            RecipeImage()
            VStack(spacing: 0) {
                RecipeTitle()
                ZStack(alignment: .top) {
                    Rectangle()
                        .foregroundStyle(Color.text)
                    ScrollView {
                        VStack {
                            RecipeContentView()
                                .padding()
                                .frame(maxWidth: .infinity)
                            NutritionalInformation()
                        }
                    }
                    .background(Color.background)
                    .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
                }            }
            .background(Color.text)
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder func RecipeImage() -> some View {
        if let imageName = recipe.imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: imageHeight)
                .overlay(alignment: .bottomLeading) {
                    CloseButton()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
        }
        if let imageUrl = recipe.imageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .placeholder {
                    Rectangle()
                        .foregroundStyle(Color.background)
                        .frame(height: imageHeight)
                }
                .aspectRatio(contentMode: .fill)
                .frame(height: imageHeight)
                .overlay(alignment: .bottomLeading) {
                    CloseButton()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
        }
    }
    
    @ViewBuilder func RecipeTitle() -> some View {
        VStack {
            Text(recipe.title)
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.background)
            Text("Serves \(recipe.servings)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.darkAccentText)
        }
        .frame(maxWidth: .infinity)
        .background(Color.text)
        .padding()
    }
    
    @ViewBuilder func RecipeContentView() -> some View {
        Markdown(recipe.markdownContent)
            .markdownTextStyle {
                ForegroundColor(Color.text)
            }
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
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.text, lineWidth: 1)
            }
            .padding()
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
                Image(systemName: "chevron.backward")
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
