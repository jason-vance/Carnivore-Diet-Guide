//
//  RecipeItemView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/16/24.
//

import SwiftUI

struct RecipeItemView: View {
    
    enum Style {
        case vertical
        case horizontal
        case largeVertical
    }
    
    @State public var recipe: Recipe
    private var style: Style
    
    private var titleFont: Font {
        switch style {
        case .vertical, .horizontal:
            .body.weight(.medium)
        case .largeVertical:
            .title2.weight(.medium)
        }
    }
    
    private var summaryFont: Font {
        switch style {
        case .vertical, .horizontal:
            .footnote.weight(.light)
        case .largeVertical:
            .body.weight(.light)
        }
    }
    
    private var imageAspectRatio: CGFloat {
        switch style {
        case .vertical, .largeVertical:
            5/4
        case .horizontal:
            1
        }
    }
    
    private var textContentHeight: CGFloat? {
        switch style {
        case .vertical:
            135
        case .horizontal:
            126
        case .largeVertical:
            165
        }
    }
    
    init(_ recipe: Recipe) {
        self.recipe = recipe
        self.style = .vertical
    }
    
    public func recipeStyle(_ style: Style) -> RecipeItemView {
        var view = self
        view.style = style
        return view
    }
    
    var body: some View {
        ItemContent()
            .taggedAsPremiumContent(recipe.isPremium)
            .background(Color.background)
            .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
            .clipped()
            .shadow(color: Color.text, radius: 4)
    }
    
    @ViewBuilder func ItemContent() -> some View {
        switch style {
        case .vertical, .largeVertical:
            VerticalContent()
        case .horizontal:
            HorizontalContent()
        }
    }
    
    @ViewBuilder func HorizontalContent() -> some View {
        HStack {
            TextContent()
                .frame(height: textContentHeight)
            Spacer(minLength: 0)
            ImageContent()
                .frame(width: 126, height: 126)
        }
    }
    
    @ViewBuilder func VerticalContent() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ImageContent()
            TextContent()
                .frame(height: textContentHeight)
        }
    }
    
    @ViewBuilder func TextContent() -> some View {
        VStack {
            RecipeTitle()
            RecipeSummary()
            Spacer(minLength: 0)
            FavoriteCount()
        }
        .foregroundStyle(Color.text)
        .padding(8)
    }
    
    @ViewBuilder func RecipeTitle() -> some View {
        HStack {
            Text(recipe.title)
                .font(titleFont)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
    }
    
    //TODO: Add ResourceSummary to Recipe
    @ViewBuilder func RecipeSummary() -> some View {
        HStack {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                .font(summaryFont)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
    }
    
    @ViewBuilder func FavoriteCount() -> some View {
        HStack {
            FavoriteCountView(resource: .init(recipe))
            Spacer(minLength: 0)
        }
    }
    
    @ViewBuilder func ImageContent() -> some View {
        ResourceImageView(url: recipe.coverImageUrl)
            .aspectRatio(imageAspectRatio)
    }
}

#Preview {
    ScrollView {
        VStack {
            RecipeItemView(.sample)
                .recipeStyle(.largeVertical)
            RecipeItemView(.longNamedSample)
                .recipeStyle(.largeVertical)
            HStack {
                RecipeItemView(.sample)
                    .recipeStyle(.vertical)
                RecipeItemView(.longNamedSample)
                    .recipeStyle(.vertical)
            }
            RecipeItemView(.sample)
                .recipeStyle(.horizontal)
            RecipeItemView(.longNamedSample)
                .recipeStyle(.horizontal)

        }
        .padding()
    }
}
