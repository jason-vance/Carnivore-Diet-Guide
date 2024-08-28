//
//  Post.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/6/24.
//

import Foundation

struct Post: Identifiable, Hashable {
    var id: String
    var title: String
    var imageUrls: [URL]
    var author: String
    var markdownContent: String
    var publicationDate: Date
}

extension Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
    }
}

extension Post {
    
    static var sample: Post {
        .init(
            id: "samplePostId",
            title: "What is the Carnivore Diet?",
            imageUrls: [
                URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/BlogPostImages%2FWhatIsTheCarnivoreDiet.jpg?alt=media&token=66c254f6-6f9a-4240-97f5-726baa84c75b")!
            ],
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
            id: "longNamedSamplePostId",
            title: "Getting Started with the Carnivore Diet. All of the Whats, Whys, and Hows.",
            imageUrls: [
                URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/BlogPostImages%2FWhatIsTheCarnivoreDiet.jpg?alt=media&token=66c254f6-6f9a-4240-97f5-726baa84c75b")!
            ],
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
