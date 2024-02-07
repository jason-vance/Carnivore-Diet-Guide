//
//  RecipeDetailMetadataView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import SwiftUI

struct RecipeDetailMetadataView: View {
    
    @State var recipe: Recipe
    @StateObject private var model = RecipeDetailMetadataViewModel()
    @State private var showCommentCount: Bool = true
    @State private var commentCount: UInt = 0
    @State private var showFavoriteCount: Bool = false
    @State private var favoriteCount: UInt = 0
    
    var body: some View {
        HStack {
            DifficultyLevelMetadataItem()
            MetadataSeparator()
            CookTimeMetadataItem()
            Spacer()
            if showCommentCount {
                CommentsMetadataItem()
            }
            if showCommentCount && showFavoriteCount {
                MetadataSeparator()
            }
            if showFavoriteCount {
                FavoritesMetadataItem()
            }
        }
        .font(.caption)
        .foregroundStyle(Color.text)
        .onChange(of: model.commentCount, initial: true) { count in
            withAnimation(.snappy) {
                showCommentCount = count > 0
                commentCount = count
            }
        }
        .onChange(of: model.favoriteCount, initial: true) { count in
            withAnimation(.snappy) {
                showFavoriteCount = count > 0
                favoriteCount = count
            }
        }
        .onChange(of: recipe, initial: true) { newRecipe in
            model.recipe = newRecipe
        }
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
        MetadataItem(text: "\(favoriteCount)", icon: "heart")
    }
    
    @ViewBuilder func CommentsMetadataItem() -> some View {
        //TODO: Get a real comment count
        MetadataItem(text: "\(commentCount)", icon: "text.bubble")
    }
    
    @ViewBuilder func MetadataItem(text: String, icon: String? = nil) -> some View {
        HStack(spacing: 2) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(text)
                .contentTransition(.numericText())
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        RecipeDetailView(recipe: .sample)
    }
}
