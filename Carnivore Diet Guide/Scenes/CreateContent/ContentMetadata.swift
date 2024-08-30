//
//  ContentMetadata.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

struct ContentMetadata: Hashable {
    
    public let id: UUID
    public let summary: Resource.Summary
    public let categories: [Resource.Category]
    public let searchKeywords: [SearchKeyword]
    
    public static let sample: ContentMetadata = .init(
        id: UUID(),
        summary: .sample,
        categories: [ .init("food")!, .init("exercise")! ],
        searchKeywords: [ .init("chicken")!, .init("running")! ]
    )
}

