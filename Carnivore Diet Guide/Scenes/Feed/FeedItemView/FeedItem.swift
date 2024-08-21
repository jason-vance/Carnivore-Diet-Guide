//
//  FeedItem.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/15/24.
//

import Foundation

struct FeedItem: Identifiable {
    
    enum FeedItemType: String, Codable {
        case post
        case recipe
        case article
    }
    
    var id: String
    var type: FeedItemType
    var resourceId: String
    var userId: String
    var imageUrls: [URL]
    var calloutText: String?
    var title: String
    var summary: String
}

extension FeedItem {
    static let sampleArticle: FeedItem = .init(
        id: "articleFeedItemId",
        type: .article,
        resourceId: "resourceId",
        userId: "userId",
        imageUrls: [
            URL(string: "https://ancestralsupplements.com/cdn/shop/articles/Modified_Carnivore_Diet.jpg?v=1698546054")!
        ],
        calloutText: "Featured Article",
        title: "What is the Carnivore Diet?",
        summary: "The carnivore diet is a dietary regimen characterized by the exclusive consumption of animal products, primarily focusing on meat. Its key characteristics include a strict elimination of all plant-based foods, resulting in a diet that is extremely low in carbohydrates and high in proteins and fats. This diet typically includes various types of meat such as beef, pork, chicken, and fish, along with eggs and, in some variations, limited dairy products like cheese and butter. It eschews fruits, vegetables, grains, nuts, and seeds, positioning itself as a counterpoint to conventional dietary guidelines. Proponents tout benefits such as weight loss, improved energy levels, enhanced mental clarity, reduction in inflammation, and potential relief from certain health conditions. The carnivore diet's emphasis on simplicity and a return to an ancestral way of eating, with a focus on whole, unprocessed animal foods, forms its core ethos."
    )
    
    static let sampleRecipe: FeedItem = .init(
        id: "recipeFeedItemId",
        type: .recipe,
        resourceId: "resourceId",
        userId: "userId",
        imageUrls: [
            URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/RecipeImages%2Fseared_ribeye_steak.jpg?alt=media&token=38c16213-c053-4f47-992a-5dd748dc529b")!
        ],
        calloutText: "Featured Recipe",
        title: "Seared Ribeye Steak",
        summary: "This Seared Ribeye Steak recipe epitomizes the essence of the carnivore diet, focusing solely on the rich, natural flavors of high-quality meat. An 8-ounce, grass-fed ribeye steak is seasoned with just salt (and optional black pepper for those who include spices in their carnivore diet) and seared in a hot skillet to achieve a perfect crust with a juicy, medium-rare center. The simplicity of this dish highlights the steak's succulent texture and deep flavors, making it a pure, satisfying meal for meat lovers. Cooked without oils, butters, or garnishes, it's a straightforward ode to the primal joy of eating well-prepared meat."
    )
    
    static let samplePost: FeedItem = .init(
        id: "postFeedItemId",
        type: .post,
        resourceId: "resourceId",
        userId: "userId",
        imageUrls: [],
        calloutText: "Featured Post",
        title: "Welcome to the Carnivore Diet Guide!",
        summary: "Are you a meat lover or curious about the health benefits of a carnivorous lifestyle? 'Carnivore Diet Guide' is your essential companion for delving into the world of the carnivore diet. Tailored for both seasoned followers and newcomers, our app offers an in-depth journey into this unique dietary choice."
    )
    
    static let samples: [FeedItem] = [sampleArticle, samplePost, sampleRecipe]
}
