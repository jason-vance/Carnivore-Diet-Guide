//
//  RecipeRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation
import FirebaseFirestore

class FirebaseRecipeRepository {
    
    private struct RecipeDoc: Codable {

        struct Localization: Codable {
            static let defaultLanguage: String = "default"
            
            var language: String?
            var title: String?
            var markdownContent: String?
        }
        
        @DocumentID var id: String?
        var publicationDate: Date?
        var author: String?
        var imageUrl: String?
        var localizations: [Localization]
        var servings: Int?
        var calories: Int?
        var protein: Int?
        var fat: Int?
        var carbohydrates: Int?
        
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

        func toRecipe() -> Recipe? {
            let localization: Localization? = {
                let languageCode = Locale.current.language.languageCode?.identifier
                
                if let localization = (localizations.first { $0.language == languageCode }) {
                    return localization
                } else if let localization = (localizations.first { $0.language == Localization.defaultLanguage }) {
                    return localization
                } else {
                    return localizations.first
                }
            }()
            guard let localization = localization else { return nil}
            
            guard let title = localization.title else { return nil }
            guard let imageUrl = imageUrl else { return nil }
            guard let author = author else { return nil }
            guard let servings = servings else { return nil }
            guard let publicationDate = publicationDate else { return nil }
            guard let markdownContent = localization.markdownContent else { return nil }

            return .init(
                title: title,
                imageUrl: imageUrl,
                author: author,
                servings: servings,
                markdownContent: markdownContent.replacingOccurrences(of: "\\n", with: "\n"),
                publicationDate: publicationDate,
                basicNutritionInfo: basicNutritionInfo
            )
        }
    }
    
    private static let RECIPES = "Recipes"
    private let PUBLICATION_DATE = "publicationDate"

    let recipesCollection = Firestore.firestore().collection(RECIPES)
    
    func getRecipesNewestToOldest(limit: Int? = nil) async throws -> [Recipe] {
        var query = recipesCollection
            .order(by: PUBLICATION_DATE, descending: true)
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents
            .compactMap { try $0.data(as: RecipeDoc.self).toRecipe() }
    }
}
