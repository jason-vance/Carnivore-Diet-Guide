//
//  BlogPost.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/6/24.
//

import Foundation

protocol BlogPostContentItem: Identifiable {
    var id: UUID { get }
}

struct BlogPost: Identifiable {
    
    struct ImageItem: BlogPostContentItem {
        var id: UUID = UUID()
        var url: String
        var caption: String?
    }
    
    struct TextItem: BlogPostContentItem {
        var id: UUID = UUID()
        var text: String
    }
    
    struct MarkdownItem: BlogPostContentItem {
        var id: UUID = UUID()
        var markdown: String
    }
    
    var id: UUID = .init()
    var title: String
    var imageName: String?
    var imageUrl: String?
    var author: String
    var content: [any BlogPostContentItem]
    var publicationDate: Date
}

extension BlogPost {
    static var sample: BlogPost {
        .init(
            title: "Getting Started with the Carnivore Diet",
            imageName: "StartingCarnivoreDiet",
            author: "The Carnivore Diet Guide Team",
            content: [
                BlogPost.TextItem(
                    text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                ),
                BlogPost.ImageItem(
                    url: "https://www.health.com/thmb/-Ph8jywWpyo4gf1jx2oiMZuLGvY=/2121x0/filters:no_upscale():max_bytes(150000):strip_icc()/CarnivoreDiet-76e2ef4d594c47a4ad6b37d08d277f17.jpg",
                    caption: "An example image"
                ),
                BlogPost.TextItem(
                    text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                ),
                BlogPost.ImageItem(
                    url: "https://ancestralsupplements.com/cdn/shop/articles/Carnivore_Diet_Macros.png?v=1698544380"
                ),
                BlogPost.TextItem(
                    text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                )
            ],
            publicationDate: Date()
        )
    }
    
    static var longNamedSample: BlogPost {
        .init(
            title: "Getting Started with the Carnivore Diet. All of the Whats, Whys, and Hows.",
            imageName: "StartingCarnivoreDiet",
            author: "The Carnivore Diet Guide Team",
            content: [
                BlogPost.TextItem(
                    text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                ),
                BlogPost.ImageItem(
                    url: "https://www.health.com/thmb/-Ph8jywWpyo4gf1jx2oiMZuLGvY=/2121x0/filters:no_upscale():max_bytes(150000):strip_icc()/CarnivoreDiet-76e2ef4d594c47a4ad6b37d08d277f17.jpg",
                    caption: "An example image"
                )
            ],
            publicationDate: Date()
        )
    }
    
    static var markdownSample: BlogPost {
        .init(
            title: "What is the Carnivore Diet?",
            imageName: "",
            author: "The Carnivore Diet Guide Team",
            content: [
                BlogPost.MarkdownItem(
                    markdown: """
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
"""
                )
            ],
            publicationDate: Date()
        )
    }
    
    static let samples: [BlogPost] = [sample, markdownSample, longNamedSample]
}
