//
//  FirestoreRecipeDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FirestoreRecipeDoc: Codable {
    
    @DocumentID var id: String?
    var isPremium: Bool?
    var author: String?
    var title: String?
    var coverImageUrl: String?
    var prepTimeMinutes: Int?
    var cookTimeMinutes: Int?
    var servings: Int?
    var difficultyLevel: String?
    var markdownContent: String?
    var publicationDate: Date?
    var calories: Int?
    var protein: Int?
    var fat: Int?
    var carbohydrates: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case isPremium
        case author
        case title
        case coverImageUrl
        case prepTimeMinutes
        case cookTimeMinutes
        case servings
        case difficultyLevel
        case markdownContent
        case publicationDate
        case calories
        case protein
        case fat
        case carbohydrates
    }
    
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
    
    static func from(recipe: Recipe) -> FirestoreRecipeDoc {
        .init(
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
