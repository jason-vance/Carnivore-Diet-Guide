//
//  FeedItem.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/15/24.
//

import Foundation

struct FeedItem {
    var id: String
    var userId: String
    var imageUrls: [URL]
    var category: String?
    var title: String
    var summary: String
}

extension FeedItem {
    static let sample: FeedItem = .init(
        id: UUID().uuidString,
        userId: "userId",
        imageUrls: [
            URL(string: "https://ancestralsupplements.com/cdn/shop/articles/Modified_Carnivore_Diet.jpg?v=1698546054")!
        ],
        category: "Featured Article",
        title: "Welcome to the Carnivore Diet Guide!",
        summary: "What is the Carnivore Diet? The carnivore diet is a dietary regimen characterized by the exclusive consumption of animal products, primarily focusing on meat. Its key characteristics include a strict elimination of all plant-based foods, resulting in a diet that is extremely low in carbohydrates and high in proteins and fats. This diet typically includes various types of meat such as beef, pork, chicken, and fish, along with eggs and, in some variations, limited dairy products like cheese and butter. It eschews fruits, vegetables, grains, nuts, and seeds, positioning itself as a counterpoint to conventional dietary guidelines. Proponents tout benefits such as weight loss, improved energy levels, enhanced mental clarity, reduction in inflammation, and potential relief from certain health conditions. The carnivore diet's emphasis on simplicity and a return to an ancestral way of eating, with a focus on whole, unprocessed animal foods, forms its core ethos."
    )
    
    static func getSample() -> FeedItem {
        var sample = FeedItem.sample
        sample.id = UUID().uuidString
        return sample
    }
}
