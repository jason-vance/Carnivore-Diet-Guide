//
//  PremiumCTAPlacement.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation

/// Where a `PremiumCTARow` is shown. The raw value is sent with the tap event, so placements can
/// be compared in Firebase Analytics.
enum PremiumCTAPlacement: String {
    case featuredArticles = "featured_articles"
    case articleList = "article_list"
    case articleDetail = "article_detail"
    case recipes = "recipes"
    case recipeDetail = "recipe_detail"
    case profile = "profile"
}
