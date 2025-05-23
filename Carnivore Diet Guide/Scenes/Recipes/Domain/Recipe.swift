//
//  Recipe.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/4/24.
//

import Foundation

struct Recipe: Identifiable {
    
    enum DifficultyLevel: String {
        case beginner
        case intermediate
        case advanced
        
        func toUiString() -> String {
            switch self {
            case .beginner:
                return String(localized: "Beginner", comment: "Difficulty level is 'Beginner'")
            case .intermediate:
                return String(localized: "Intermediate", comment: "Difficulty level is 'Intermediate'")
            case .advanced:
                return String(localized: "Advanced", comment: "Difficulty level is 'Advanced'")
            }
        }
    }
    
    var id: String
    let isPremium: Bool
    var author: String
    var title: String
    let coverImageUrl: URL
    let summary: Resource.Summary
    var prepTimeMinutes: UInt
    var cookTimeMinutes: UInt
    var servings: UInt
    var difficultyLevel: DifficultyLevel
    var markdownContent: String
    var publicationDate: Date
    var basicNutritionInfo: BasicNutritionInfo?
    var keywords: Set<SearchKeyword>
    
    init(
        id: String,
        isPremium: Bool,
        author: String,
        title: String,
        coverImageUrl: URL,
        summary: Resource.Summary,
        prepTimeMinutes: UInt,
        cookTimeMinutes: UInt,
        servings: UInt,
        difficultyLevel: DifficultyLevel,
        markdownContent: String, 
        publicationDate: Date,
        basicNutritionInfo: BasicNutritionInfo? = nil
    ) {
        self.id = id
        self.isPremium = isPremium
        self.author = author
        self.title = title
        self.coverImageUrl = coverImageUrl
        self.summary = summary
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.servings = servings
        self.difficultyLevel = difficultyLevel
        self.markdownContent = markdownContent
        self.publicationDate = publicationDate
        self.basicNutritionInfo = basicNutritionInfo
        
        let string = "\(title)\n\(summary.text)\n\(markdownContent.stripMarkdown())"
        self.keywords = SearchKeyword.keywordsFrom(string: string)
    }
}

extension Recipe: Equatable {
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

extension Recipe: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Recipe {
    static let sample = Recipe(
        id: "sampleRecipeId",
        isPremium: false,
        author: "author",
        title: "Seared Ribeye Steak",
        coverImageUrl: URL(string: "https://cdn.apartmenttherapy.info/image/upload/f_jpg,q_auto:eco,c_fill,g_auto,w_1500,ar_1:1/k%2FPhoto%2FRecipes%2F2023-06-ribeye-steak%2Fribeye-steak-043")!,
        summary: .init("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")!,
        prepTimeMinutes: 5,
        cookTimeMinutes: 12,
        servings: 5,
        difficultyLevel: .beginner,
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
        publicationDate: .now,
        basicNutritionInfo: .sample
    )
    
    static let longNamedSample = Recipe(
        id: "longNamedSampleRecipeId",
        isPremium: true,
        author: "author",
        title: "Grilled Salmon with Lemon Butter and Various Garnishes",
        coverImageUrl: URL(string: "https://www.lecremedelacrumb.com/wp-content/uploads/2022/07/grilled-lemon-butter-salmon-9smb-7.jpg")!,
        summary: .init("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")!,
        prepTimeMinutes: 10,
        cookTimeMinutes: 15,
        servings: 3,
        difficultyLevel: .intermediate,
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
        publicationDate: .now,
        basicNutritionInfo: .sample
    )
    
    static let samples: [Recipe] = [sample, longNamedSample]
}
