//
//  Ingredient.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/23/24.
//

import Foundation

extension Recipe {
    //TODO: Maybe I should remove Identifiable, it's not actually a part of `Ingredient`
    struct Ingredient: Identifiable {
        var id = UUID().uuidString
        var amount: Double?
        var unit: Self.Unit?
        var name: String
        var notes: String?
        
        var amountString: String? {
            //TODO: Should I make this fancy, ie. 1.5 -> 1 1/2
            
            guard let amount = amount else { return nil }
            
            return amount.formatted()
        }
    }
}

extension Recipe.Ingredient: Equatable {
    static func == (lhs: Recipe.Ingredient, rhs: Recipe.Ingredient) -> Bool {
        lhs.id == rhs.id
    }
}

extension Recipe.Ingredient {
    static let samples: [Recipe.Ingredient] = [
        Recipe.Ingredient(
            amount: 500,
            unit: .grams,
            name: "Spaghetti"
        ),
        Recipe.Ingredient(
            amount: 400,
            unit: .grams,
            name: "Ground beef"
        ),
        Recipe.Ingredient(
            amount: 0.75,
            name: "Onion"
        ),
        Recipe.Ingredient(
            amount: 1,
            name: "Can of tomato sauce"
        ),
        Recipe.Ingredient(
            amount: 1,
            name: "Clove of Garlic"
        ),
        Recipe.Ingredient(
            name: "Salt and pepper",
            notes: "To taste"
        ),
    ]
}
