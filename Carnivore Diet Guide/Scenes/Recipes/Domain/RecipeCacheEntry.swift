//
//  RecipeCacheEntry.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/16/24.
//

import Foundation

struct RecipeCacheEntry: Codable {
    
    private static var randomRefreshAfterDate: Date {
        let minLifetimeDays = 5
        let maxLifetimeDays = 9
        let days = Int.random(in: minLifetimeDays...maxLifetimeDays)
        return Calendar.current.date(byAdding: .day, value: days, to: .now)!
    }
    
    let refreshAfterDate: Date?
    
    let id: String?
    var isPremium: Bool?
    var author: String?
    var title: String?
    var coverImageUrl: String?
    var prepTimeMinutes: UInt?
    var cookTimeMinutes: UInt?
    var servings: UInt?
    var difficultyLevel: String?
    var markdownContent: String?
    var publicationDate: Date?
    var calories: UInt?
    var protein: UInt?
    var fat: UInt?
    var carbohydrates: UInt?
    
    private var basicNutritionInfo: BasicNutritionInfo? {
        guard let calories = calories else { return nil }
        guard let protein = protein else { return nil }
        guard let fat = fat else { return nil }
        guard let carbohydrates = carbohydrates else { return nil }
        
        return .init(
            calories: calories,
            protein: protein,
            fat: fat,
            carbohydrates: carbohydrates
        )
    }
    
    static func from(_ recipe: Recipe) -> RecipeCacheEntry {
        .init(
            refreshAfterDate: Self.randomRefreshAfterDate,
            id: recipe.id,
            isPremium: recipe.isPremium,
            author: recipe.author,
            title: recipe.title,
            coverImageUrl: recipe.coverImageUrl.absoluteString,
            prepTimeMinutes: recipe.prepTimeMinutes,
            cookTimeMinutes: recipe.cookTimeMinutes,
            servings: recipe.servings,
            difficultyLevel: recipe.difficultyLevel.rawValue,
            markdownContent: recipe.markdownContent,
            publicationDate: recipe.publicationDate,
            calories: recipe.basicNutritionInfo?.calories,
            protein: recipe.basicNutritionInfo?.protein,
            fat: recipe.basicNutritionInfo?.fat,
            carbohydrates: recipe.basicNutritionInfo?.carbohydrates
        )
    }
    
    func toRecipe() -> Recipe? {
        guard let id = id else { return nil }
        guard let author = author else { return nil }
        guard let title = title else { return nil }
        guard let coverImageUrl = URL(string: coverImageUrl ?? "") else { return nil }
        guard let prepTimeMinutes = prepTimeMinutes else { return nil }
        guard let cookTimeMinutes = cookTimeMinutes else { return nil }
        guard let servings = servings else { return nil }
        guard let difficultyLevel = Recipe.DifficultyLevel(rawValue: difficultyLevel ?? "") else { return nil }
        guard let markdownContent = markdownContent else { return nil }
        guard let publicationDate = publicationDate else { return nil }

        return .init(
            id: id,
            isPremium: isPremium ?? true,
            author: author,
            title: title,
            coverImageUrl: coverImageUrl,
            prepTimeMinutes: prepTimeMinutes,
            cookTimeMinutes: cookTimeMinutes,
            servings: servings,
            difficultyLevel: difficultyLevel,
            markdownContent: markdownContent,
            publicationDate: publicationDate,
            basicNutritionInfo: basicNutritionInfo
        )
    }
}
