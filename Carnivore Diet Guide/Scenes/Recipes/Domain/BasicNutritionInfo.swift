//
//  BasicNutritionInfo.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/5/24.
//

import Foundation

struct BasicNutritionInfo: Hashable {
    var calories: UInt
    var protein: UInt
    var fat: UInt
    var carbohydrates: UInt
    
    init?(calories: UInt, protein: UInt, fat: UInt, carbohydrates: UInt) {
        let calculatedTotalCals: UInt = (protein * 4) + (fat * 9) + (carbohydrates * 4)
        let diff = abs(Int(calculatedTotalCals) - Int(calories))
        guard diff < Int(Double(calories) * 0.15) else { return nil }
        
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbohydrates = carbohydrates
    }
    
    func toSingleLineString() -> String {
        "\(calories)cals, \(carbohydrates)carbs, \(fat)fat, \(protein)protein"
    }
}

extension BasicNutritionInfo {
    static let sample: BasicNutritionInfo = .init(
        calories: 300,
        protein: 10,
        fat: 12,
        carbohydrates: 40
    )!
}
