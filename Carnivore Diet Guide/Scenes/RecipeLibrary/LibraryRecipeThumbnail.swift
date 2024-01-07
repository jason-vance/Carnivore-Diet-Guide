//
//  LibraryRecipeThumbnail.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import SwiftUI

struct LibraryRecipeThumbnail: View {
    
    @State var recipe: Recipe
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(recipe.title)
                    .font(.system(size: 18, weight: .heavy))
                    .lineLimit(1)
                    .foregroundStyle(Color.background)
                HStack {
                    Text("Serves \(recipe.basicNutritionInfo.servings)")
                    Rectangle().frame(width: 1)
                    Text("\(recipe.basicNutritionInfo.calories) kcal")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.darkAccentText)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.text)
            Image(recipe.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .offset(y: 20)
                .clipped()
        }
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.darkAccentText ,radius: 4)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScrollView {
        VStack {
            LibraryRecipeThumbnail(recipe: .sample)
            LibraryRecipeThumbnail(recipe: .longNamedSample)
            LibraryRecipeThumbnail(recipe: .sample)
        }
        .padding()
    }
    .background(Color.background)
}
