//
//  LibraryRecipeThumbnail.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import SwiftUI
import Kingfisher

struct LibraryRecipeThumbnail: View {
    
    let imageHeight: CGFloat = 200
    let imageOffset: CGFloat = 20
    
    @State var recipe: Recipe
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(recipe.title)
                    .font(.system(size: 18, weight: .heavy))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color.background)
                HStack {
                    Text("Serves \(recipe.servings)")
                    if let calories = recipe.basicNutritionInfo?.calories {
                        Rectangle().frame(width: 1)
                        Text("\(calories) kcal")
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.darkAccentText)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.text)
            if let imageName = recipe.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: imageHeight)
                    .offset(y: imageOffset)
                    .clipped()
            }
            if let imageUrl = recipe.imageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .foregroundStyle(Color.background)
                            .frame(height: imageHeight)
                            .offset(y: -imageOffset)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(height: imageHeight)
                    .offset(y: imageOffset)
                    .clipped()
            }
        }
        .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
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
