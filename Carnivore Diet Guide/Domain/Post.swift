//
//  Post.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/6/24.
//

import Foundation

protocol PostContentItem: Identifiable {
    var id: UUID { get }
}

struct Post: Identifiable {
    
    var id: UUID = .init()
    var title: String
    var imageName: String?
    var imageUrl: String?
    var author: String
    var markdownContent: String
    var publicationDate: Date
}

extension Post {
    
    static var sample: Post {
        .init(
            title: "What is the Carnivore Diet?",
            imageName: "WhatIsTheCarnivoreDiet",
            author: "The Carnivore Diet Guide Team",
            markdownContent: """
The carnivore diet is an eating plan that focuses almost exclusively on meat and animal products, eliminating most other food groups. This diet is a more extreme version of low-carbohydrate, high-protein diets like the ketogenic and paleo diets.

### Origin and Popularity

The carnivore diet has gained popularity in recent years, partly due to anecdotal reports of health benefits and endorsements from high-profile individuals. It's often considered a reaction against plant-based diets, emphasizing the consumption of meat as a source of all necessary nutrients.

### Dietary Composition

At its core, the carnivore diet consists of:

1. **Meat**: Primarily red meat (beef, lamb), but also pork, poultry, and fish.
2. **Animal Products**: Eggs and certain dairy products, although some adherents opt for a purely meat-based diet.

Fruits, vegetables, nuts, seeds, grains, and legumes are excluded. Some versions of the diet allow for minimal consumption of certain dairy products like cheese and butter.

### Proposed Benefits

Proponents of the carnivore diet claim several health benefits, including:

- **Weight Loss**: Due to high protein and fat content, which can increase satiety.
- **Improved Blood Sugar Levels**: The lack of carbohydrates means blood sugar levels may stabilize.
- **Reduced Inflammation**: Some believe that removing plant-based foods can reduce inflammation in the body.

### Criticisms and Health Concerns

However, the diet is not without its critics. Major concerns include:

- **Nutritional Deficiencies**: The exclusion of fruits, vegetables, and grains may result in deficiencies in vitamins, minerals, and dietary fiber.
- **Heart Health Risks**: High intake of red and processed meat is linked to increased risks of heart disease and certain cancers.
- **Environmental Impact**: A meat-centric diet raises concerns about sustainability and animal welfare.

### Conclusion

While the carnivore diet may offer short-term benefits for weight loss or blood sugar control, its long-term health implications are unclear. It contradicts the widely accepted dietary guidelines that emphasize a balanced intake of all food groups. As with any diet, it's crucial to consult healthcare professionals before making significant dietary changes, especially ones as drastic as the carnivore diet.
""",
            publicationDate: Date()
        )
    }
    
    static var longNamedSample: Post {
        .init(
            title: "Getting Started with the Carnivore Diet. All of the Whats, Whys, and Hows.",
            imageName: "WhatIsTheCarnivoreDiet",
            author: "The Carnivore Diet Guide Team",
            markdownContent: """
The carnivore diet is an eating plan that focuses almost exclusively on meat and animal products, eliminating most other food groups. This diet is a more extreme version of low-carbohydrate, high-protein diets like the ketogenic and paleo diets.

### Origin and Popularity

The carnivore diet has gained popularity in recent years, partly due to anecdotal reports of health benefits and endorsements from high-profile individuals. It's often considered a reaction against plant-based diets, emphasizing the consumption of meat as a source of all necessary nutrients.

### Dietary Composition

At its core, the carnivore diet consists of:

1. **Meat**: Primarily red meat (beef, lamb), but also pork, poultry, and fish.
2. **Animal Products**: Eggs and certain dairy products, although some adherents opt for a purely meat-based diet.

Fruits, vegetables, nuts, seeds, grains, and legumes are excluded. Some versions of the diet allow for minimal consumption of certain dairy products like cheese and butter.

### Proposed Benefits

Proponents of the carnivore diet claim several health benefits, including:

- **Weight Loss**: Due to high protein and fat content, which can increase satiety.
- **Improved Blood Sugar Levels**: The lack of carbohydrates means blood sugar levels may stabilize.
- **Reduced Inflammation**: Some believe that removing plant-based foods can reduce inflammation in the body.

### Criticisms and Health Concerns

However, the diet is not without its critics. Major concerns include:

- **Nutritional Deficiencies**: The exclusion of fruits, vegetables, and grains may result in deficiencies in vitamins, minerals, and dietary fiber.
- **Heart Health Risks**: High intake of red and processed meat is linked to increased risks of heart disease and certain cancers.
- **Environmental Impact**: A meat-centric diet raises concerns about sustainability and animal welfare.

### Conclusion

While the carnivore diet may offer short-term benefits for weight loss or blood sugar control, its long-term health implications are unclear. It contradicts the widely accepted dietary guidelines that emphasize a balanced intake of all food groups. As with any diet, it's crucial to consult healthcare professionals before making significant dietary changes, especially ones as drastic as the carnivore diet.
""",
            publicationDate: Date()
        )
    }
    
    static let samples: [Post] = [sample, longNamedSample]
}
