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
    public let categories: Set<Resource.Category>
    public let searchKeywords: Set<SearchKeyword>
    
    public static let sample: ContentMetadata = .init(
        id: UUID(),
        summary: .sample,
        categories: Set(Resource.Category.samples),
        searchKeywords: Set(SearchKeyword.samples)
    )
}

