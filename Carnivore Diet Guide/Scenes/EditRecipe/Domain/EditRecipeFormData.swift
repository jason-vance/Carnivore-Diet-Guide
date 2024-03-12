//
//  EditRecipeFormData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/12/24.
//

import Foundation

struct EditRecipeFormData {
    let resourceImageUrl: URL
    let resourceTitle: ResourceTitle
    let difficultyLevel: Recipe.DifficultyLevel
    let cookTime: GreaterThanZeroMicrowaveTime
    let servings: GreaterThanZeroInt
    let summary: ResourceSummary
    let markdownContent: ResourceMarkdownContent
    let basicNutritionInfo: BasicNutritionInfo
}
