//
//  IngredientUnit.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/23/24.
//

import Foundation

extension Recipe.Ingredient {
    struct Unit {
        var name: String
        var abbreviation: String?
        
        var displayString: String { abbreviation ?? name }
        
        init?(name: String, abbreviation: String? = nil) {
            do {
                try Self.validate(name: name, abbreviation: abbreviation)
                self.name = name
                self.abbreviation = abbreviation
            } catch {
                return nil
            }
        }
        
        private static func validate(name: String, abbreviation: String?) throws {
            guard !name.isEmpty else { throw "Name is empty"}
            if abbreviation != nil {
                guard !(abbreviation!.isEmpty) else { throw "Abbreviation was given, but is empty"}
            }
        }
    }
}

extension Recipe.Ingredient.Unit: Hashable { }

extension Recipe.Ingredient.Unit {
    
    static let all: [Self] = [
        .teaspoons, .tablespoons, .fluidOunces, .cups,
        .pints, .quarts, .gallons, .ounces, .pounds,
        .grams, .kilograms, .pinch, .dash, .handful
    ]
    
    static let teaspoons: Self = .init(
        name: String(localized: "Teaspoons"),
        abbreviation: String(localized: "tsp", comment: "Abbreviation of teaspoons")
    )!
    
    static let tablespoons: Self = .init(
        name: String(localized: "Tablespoons"),
        abbreviation: String(localized: "tbsp", comment: "Abbreviation of tablespoons")
    )!
    
    static let fluidOunces: Self = .init(
        name: String(localized: "Fluid Ounces"),
        abbreviation: String(localized: "fl oz", comment: "Abbreviation of fluid ounces")
    )!
    
    static let cups: Self = .init(name: String(localized: "Cups"))!
    
    static let pints: Self = .init(
        name: String(localized: "Pints"),
        abbreviation: String(localized: "pt", comment: "Abbreviation of pints")
    )!
    
    static let quarts: Self = .init(
        name: String(localized: "Quarts"),
        abbreviation: String(localized: "qt", comment: "Abbreviation of quarts")
    )!
    
    static let gallons: Self = .init(
        name: String(localized: "Gallons"),
        abbreviation: String(localized: "gal", comment: "Abbreviation of gallons")
    )!
    
    static let ounces: Self = .init(
        name: String(localized: "Ounces"),
        abbreviation: String(localized: "oz", comment: "Abbreviation of ounces")
    )!
    
    static let pounds: Self = .init(
        name: String(localized: "Pounds"),
        abbreviation: String(localized: "lb", comment: "Abbreviation of pounds")
    )!
    
    static let grams: Self = .init(
        name: String(localized: "Grams"),
        abbreviation: String(localized: "g", comment: "Abbreviation of grams")
    )!
    
    static let kilograms: Self = .init(
        name: String(localized: "Kilograms"),
        abbreviation: String(localized: "kg", comment: "Abbreviation of kilograms")
    )!
    
    static let pinch: Self = .init(name: String(localized: "Pinch", comment: "As in, a pinch of salt"))!
    static let dash: Self = .init(name: String(localized: "Dash", comment: "As in, a dash of salt"))!
    static let handful: Self = .init(name: String(localized: "Handful", comment: "As in, a handful of flour"))!
}
