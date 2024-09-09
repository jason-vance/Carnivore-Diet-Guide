//
//  FeaturedArticles.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/7/24.
//

import Foundation

struct FeaturedArticles {
    let sections: [Section]
    let publicationDate: Date
    
    init?(sections: [Section], publicationDate: Date) {
        
        guard !sections.isEmpty else { return nil }
        
        self.sections = sections
        self.publicationDate = publicationDate
    }
    
    static let sample: FeaturedArticles = .init(
        sections: [.sampleCollage],
        publicationDate: .now
    )!
}

extension FeaturedArticles {
    struct Section: Identifiable {
        let id: UUID
        let layout: Layout
        let title: FeaturedSectionTitle
        let description: FeaturedSectionDescription?
        let content: [Item]
        
        init?(
            id: UUID,
            layout: Layout,
            title: FeaturedSectionTitle,
            description: FeaturedSectionDescription?,
            content: [Item]
        ) {
            guard Self.content(content, matches: layout) else { return nil }
            
            self.id = id
            self.layout = layout
            self.title = title
            self.description = description
            self.content = content
        }
        
        static func content(_ content: [Item], matches layout: Layout) -> Bool {
            guard !content.isEmpty else { return false }
            
            switch layout {
            case .collage:
                return content.filter { $0.prominence == .secondary }.count % 2 == 0
            }
        }
        
        static let sampleCollage: Section = .init(
            id: UUID(),
            layout: .collage,
            title: .init("For You")!,
            description: .init("Recommendations based on topics you read"),
            content: [.samplePrimary, .sampleSecondary, .sampleSecondary2, .sampleTertiary]
        )!
    }
}

extension FeaturedArticles.Section {
    enum Layout: CaseIterable {
        case collage
        
        var displayName: String {
            switch self {
            case .collage: String(localized: "Collage")
            }
        }
    }
}

extension FeaturedArticles.Section {
    struct Item: Identifiable {
        let id: UUID
        let article: Article
        let prominence: Prominence
        
        static let samplePrimary: Item = .init(id: UUID(), article: .sample, prominence: .primary)
        static let sampleSecondary: Item = .init(id: UUID(), article: .sample, prominence: .secondary)
        static let sampleSecondary2: Item = .init(id: UUID(), article: .sample2, prominence: .secondary)
        static let sampleTertiary: Item = .init(id: UUID(), article: .sample, prominence: .tertiary)
    }
}

extension FeaturedArticles.Section.Item {
    enum Prominence {
        case primary
        case secondary
        case tertiary
    }
}


