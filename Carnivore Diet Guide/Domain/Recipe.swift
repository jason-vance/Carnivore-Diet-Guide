//
//  Recipe.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/4/24.
//

import Foundation

struct Recipe: Identifiable {
    var id: UUID = .init()
    var title: String
    var imageName: String
    var ingredients: [String]
    var cookingSteps: [String]
    var basicNutritionInfo: BasicNutritionInfo
}

extension Recipe {
    static let sample: Recipe = .init(
        title: "Seared Ribeye Steak",
        imageName: "SearedRibeyeSteak",
        ingredients: [
            "500g spaghetti",
            "400g ground beef",
            "1 onion",
            "1 can of tomato sauce",
            "1 clove of garlic",
            "Salt and pepper to taste"
        ],
        cookingSteps: [
            "Boil spaghetti until al dente.",
            "Brown ground beef with onions and garlic.",
            "Add tomato sauce and season with salt and pepper.",
            "Serve sauce over cooked spaghetti.",
            "Enjoy!",
        ],
        basicNutritionInfo: .sample
    )
    
    static let samples: [Recipe] = [
        sample, sample, sample, sample
    ]
}
