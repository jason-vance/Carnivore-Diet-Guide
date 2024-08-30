//
//  CreateArticleMetadataViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

@MainActor
class CreateArticleMetadataViewModel: ObservableObject {
    
    @Published public var articleSummary: Resource.Summary? = nil
    @Published public var articleCategories: [Resource.Category] = []
    @Published public var articleSearchKeywords: [SearchKeyword] = []
    
    public var isFormEmpty: Bool {
        articleSummary == nil || articleCategories.isEmpty || articleSearchKeywords.isEmpty
    }
    
    public var contentMetadata: ContentMetadata? {
        //TODO: Implement CreateArticleMetadataViewModel.contentMetadata { get }
        return nil
    }
}
