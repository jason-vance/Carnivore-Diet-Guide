//
//  RecipeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/17/24.
//

import SwiftUI
import MarkdownUI

struct RecipeView: View {
    
    let recipe: Recipe
    
    var body: some View {
        VStack(spacing: 0) {
            ResourceImageViewPager(urls: [recipe.coverImageUrl])
            VStack(spacing: 0) {
                RecipeMetadata()
                Title()
//                ServingsView()
                ByLineView(userId: recipe.author)
                RecipeContent()
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }
    
    @ViewBuilder func RecipeMetadata() -> some View {
        HStack {
            CookTimeView()
            MetadataSeparatorView()
            ServingsView()
            MetadataSeparatorView()
            DifficultyLevelView()
            Spacer()
            CommentCountView(resource: .init(recipe))
            MetadataSeparatorView()
            FavoriteCountView(resource: .init(recipe))
        }
    }
    
    @ViewBuilder func CookTimeView() -> some View {
        MetadataItemView(
            text: "\(CookTimeFormatter.formatMinutes(recipe.prepTimeMinutes + recipe.cookTimeMinutes))",
            icon: "clock"
        )
    }
    
    @ViewBuilder func ServingsView() -> some View {
        MetadataItemView(
            text: "Serves \(recipe.servings)",
            icon: "fork.knife"
        )
    }
    
    @ViewBuilder func DifficultyLevelView() -> some View {
        MetadataItemView(
            text: "\(recipe.difficultyLevel.toUiString())",
            icon: "frying.pan"
        )
    }
    
    @ViewBuilder func Title() -> some View {
        Text(recipe.title)
            .font(.system(size: 32, weight: .black))
            .foregroundStyle(Color.text)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder func RecipeContent() -> some View {
        Markdown(recipe.markdownContent)
            .markdownTextStyle {
                ForegroundColor(Color.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ScrollView {
            RecipeView(recipe: .sample)
        }
    }
}
