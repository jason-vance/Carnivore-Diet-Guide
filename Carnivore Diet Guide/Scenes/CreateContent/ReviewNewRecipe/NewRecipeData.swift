//
//  NewRecipeData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/17/24.
//

import Foundation

struct NewRecipeData: Hashable {
    let data: ContentData
    let metadata: RecipeMetadata
    
    static let sample: NewRecipeData = .init(data: .sample, metadata: .sample)
}
