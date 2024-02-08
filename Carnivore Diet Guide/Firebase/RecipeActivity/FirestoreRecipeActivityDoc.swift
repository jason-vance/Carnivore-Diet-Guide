//
//  FirestoreRecipeActivityDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FirestoreRecipeActivityDoc: Codable {
    
    enum RecipeActivityType: String, Codable {
        case creation
        case view
        case favorite
        case comment
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case activityType
        case userId
        case recipeId
        case date
    }
    
    @DocumentID var id: String?
    var activityType: RecipeActivityType?
    var userId: String?
    var recipeId: String?
    var date: Date?
}
