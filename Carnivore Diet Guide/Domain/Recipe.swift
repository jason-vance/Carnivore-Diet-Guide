//
//  Recipe.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/4/24.
//

import Foundation

struct Recipe: Identifiable {
    
    enum DifficultyLevel: String {
        case unknown
        case easy
        case intermediate
        case hard
        
        func toUiString() -> String {
            switch self {
            case .unknown:
                return String(localized: "Unknown", comment: "Difficulty level is 'Unknown'")
            case .easy:
                return String(localized: "Easy", comment: "Difficulty level is 'Easy'")
            case .intermediate:
                return String(localized: "Intermediate", comment: "Difficulty level is 'Intermediate'")
            case .hard:
                return String(localized: "Hard", comment: "Difficulty level is 'Hard'")
            }
        }
    }
    
    var id: String
    var title: String
    var imageName: String?
    var imageUrl: String?
    var authorUserId: String
    var servings: Int
    var difficultyLevel: DifficultyLevel
    var markdownContent: String
    var publicationDate: Date
    var basicNutritionInfo: BasicNutritionInfo?
}
 
extension Recipe: Equatable {
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

extension Recipe {
    static let sample = Recipe(
        id: "sampleRecipeId",
        title: "Seared Ribeye Steak",
        imageName: "SearedRibeyeSteak",
        authorUserId: "authorUserId",
        servings: 5,
        difficultyLevel: .easy,
        markdownContent: """
### Ingredients

- 500g spaghetti
- 400g ground beef
- 1 onion
- 1 can of tomato sauce
- 1 clove of garlic
- Salt and pepper to taste

### Cooking Steps

1. Boil spaghetti until al dente.
2. Brown ground beef with onions and garlic.
3. Add tomato sauce and season with salt and pepper.
4. Serve sauce over cooked spaghetti.
5. Enjoy!
""",
        publicationDate: Date(),
        basicNutritionInfo: .sample
    )
    
    static let longNamedSample = Recipe(
        id: "longNamedSampleRecipeId",
        title: "Grilled Salmon with Lemon Butter and Various Garnishes",
        imageName: "GrilledSalmonWithLemonButter",
        authorUserId: "authorUserId",
        servings: 5,
        difficultyLevel: .easy,
        markdownContent: """
### Ingredients

- 500g spaghetti
- 400g ground beef
- 1 onion
- 1 can of tomato sauce
- 1 clove of garlic
- Salt and pepper to taste

### Cooking Steps

1. Boil spaghetti until al dente.
2. Brown ground beef with onions and garlic.
3. Add tomato sauce and season with salt and pepper.
4. Serve sauce over cooked spaghetti.
5. Enjoy!
""",
        publicationDate: Date(),
        basicNutritionInfo: .sample
    )
    
    static let samples: [Recipe] = [sample, longNamedSample]
}
