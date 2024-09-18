//
//  CreateRecipeMetadataViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/16/24.
//

import Foundation
import SwiftUI

@MainActor
class CreateRecipeMetadataViewModel: ObservableObject {
    
    @Published public var recipeTitle: String = ""
    @Published public var recipeContent: String = ""
    @Published public var recipeSummary: Resource.Summary? = nil
    @Published public var recipePublicationDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
    @Published public var recipePrepTimeMinutes: UInt? = nil
    @Published public var recipeCookTimeMinutes: UInt? = nil
    @Published public var recipeServings: UInt? = nil
    @Published public var recipeDifficultyLevel: Recipe.DifficultyLevel = .beginner
    @Published public var recipeNutritionInfo: BasicNutritionInfo? = nil

    public var recipeSearchKeywords: Set<SearchKeyword> {
        let keywordText = "\(recipeTitle)\n\(recipeContent)\n\(recipeSummary?.text ?? "")"
        return SearchKeyword.keywordsFrom(string: keywordText)
    }
    
    public var isFormChanged: Bool {
        recipeSummary != nil ||
        recipePrepTimeMinutes != nil ||
        recipeCookTimeMinutes != nil ||
        recipeServings != nil ||
        recipeDifficultyLevel != .beginner ||
        recipeNutritionInfo != nil
    }
    
    public func getRecipeMetadata(id: UUID) -> RecipeMetadata? {
        guard let recipeSummary = recipeSummary else { return nil }
        guard let recipePrepTimeMinutes = recipePrepTimeMinutes else { return nil }
        guard let recipeCookTimeMinutes = recipeCookTimeMinutes else { return nil }
        guard let recipeServings = recipeServings else { return nil }
        guard !recipeSearchKeywords.isEmpty else { return nil }

        return .init(
            id: id,
            summary: recipeSummary,
            publicationDate: recipePublicationDate,
            prepTimeMinutes: recipePrepTimeMinutes,
            cookTimeMinutes: recipeCookTimeMinutes,
            servings: recipeServings,
            difficultyLevel: recipeDifficultyLevel,
            basicNutritionInfo: recipeNutritionInfo
        )
    }
    
    public func set(title: String, markdownContent: String) {
        self.recipeTitle = title
        self.recipeContent = markdownContent.stripMarkdown()
    }    
}
