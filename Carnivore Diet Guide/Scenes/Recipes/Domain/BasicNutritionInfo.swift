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
}

extension BasicNutritionInfo {
    static let sample: BasicNutritionInfo = .init(
        calories: 300,
        protein: 10,
        fat: 12,
        carbohydrates: 40
    )
}
