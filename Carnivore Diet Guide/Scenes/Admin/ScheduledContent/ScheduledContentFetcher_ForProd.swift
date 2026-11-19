//
//  ScheduledContentFetcher_ForProd.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/18/26.
//

import Foundation

extension ScheduledContentFetcher {
    static let forProd = ScheduledContentFetcher {
        // Straight from Firestore rather than the libraries, which only fetch on launch, so anything
        // published since shows up too.
        async let articles = FirebaseArticleRepository().fetchScheduledArticles()
        async let recipes = FirebaseRecipeRepository().fetchScheduledRecipes()
        return try await ScheduledContent(articles: articles, recipes: recipes)
    }
}
