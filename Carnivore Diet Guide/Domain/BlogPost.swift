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
    
    static let samples: [BlogPost] = [sample, longNamedSample, sample, longNamedSample]
}
