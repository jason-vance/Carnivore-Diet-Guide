//
//  ReviewPostData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/21/24.
//

import Foundation

struct ReviewPostData: Hashable {
    public let id: String
    public let userId: String
    public let title: String
    public let markdownContent: String
    public let imageUrls: [URL]
    
    public static let sample: ReviewPostData = .init(
        id: "reviewPostDataId",
        userId: UserData.sample.id,
        title: "Welcome to the Carnivore Diet Guide",
        markdownContent: """
### Lorem ipsum dolor sit amet.

1. **Consectetur adipiscing elit**, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
2. **Ut enim ad minim veniam**, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
""",
        imageUrls: [
            URL(string: "https://plantbasednews.org/app/uploads/2023/04/plant-based-news-what-is-carnivore-diet.jpg")!,
            URL(string: "https://www.health.com/thmb/jSs3XW5otqOQmCXkwyCcS3PADCw=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/CarnivoreDiet-76e2ef4d594c47a4ad6b37d08d277f17.jpg")!,
            URL(string: "https://b2976109.smushcdn.com/2976109/wp-content/uploads/2023/09/carnivorediet.jpeg?lossy=2&strip=1&webp=1")!
        ]
    )
}
