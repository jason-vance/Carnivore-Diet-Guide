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
    var imageName: String?
    var imageUrl: String?
    var author: String
    var markdownContent: String
    var publicationDate: Date
    var basicNutritionInfo: BasicNutritionInfo
}

extension Recipe {
    static var sample: Recipe {
        .init(
            title: "Seared Ribeye Steak",
            imageName: "SearedRibeyeSteak",
            author: "The Carnivore Diet Guide Team",
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
    }
    
    static var longNamedSample: Recipe {
        .init(
            title: "Grilled Salmon with Lemon Butter and Various Garnishes",
            imageName: "GrilledSalmonWithLemonButter",
            author: "The Carnivore Diet Guide Team",
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
    }
    
    static let samples: [Recipe] = [sample, longNamedSample, sample, longNamedSample]
}
