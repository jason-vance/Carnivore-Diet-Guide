//
//  RecipeMetadata.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/16/24.
//

import Foundation

struct RecipeMetadata: Hashable {
    
    public let id: UUID
    public let summary: Resource.Summary
    public let publicationDate: Date
    public let prepTimeMinutes: UInt
    public let cookTimeMinutes: UInt
    public let servings: UInt
    public let difficultyLevel: Recipe.DifficultyLevel
    public let basicNutritionInfo: BasicNutritionInfo?
    
    public static let sample: RecipeMetadata = .init(
        id: UUID(),
        summary: .sample,
        publicationDate: .now,
        prepTimeMinutes: 5,
        cookTimeMinutes: 10,
        servings: 1,
        difficultyLevel: .beginner,
        basicNutritionInfo: .sample
    )
}

