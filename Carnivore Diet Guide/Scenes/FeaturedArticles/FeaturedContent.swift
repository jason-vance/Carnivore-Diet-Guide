//
//  FeaturedContent.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/7/24.
//

import Foundation

struct FeaturedContent {
    let sections: [Section]
    
    static let sample: FeaturedContent = .init(sections: [.sample])
}

extension FeaturedContent {
    struct Section: Identifiable {
        let id: UUID
        let layout: Layout
        let title: String
        let description: String?
        let content: [Item]
        
        static let sample: Section = .init(
            id: UUID(),
            layout: .collage,
            title: "For You",
            description: "Recommendations based on topics you read",
            content: [.samplePrimary, .sampleSecondary, .sampleTertiary]
        )
    }
}

extension FeaturedContent.Section {
    enum Layout {
        case collage
    }
}

extension FeaturedContent.Section {
    struct Item: Identifiable {
        let id: UUID
        let item: Article
        let prominence: Prominence
        
        static let samplePrimary: Item = .init(id: UUID(), item: .sample, prominence: .primary)
        static let sampleSecondary: Item = .init(id: UUID(), item: .sample, prominence: .secondary)
        static let sampleTertiary: Item = .init(id: UUID(), item: .sample, prominence: .tertiary)
    }
}

extension FeaturedContent.Section.Item {
    enum Prominence {
        case primary
        case secondary
        case tertiary
    }
}


