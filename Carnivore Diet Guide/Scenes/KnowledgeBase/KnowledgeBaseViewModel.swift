//
//  KnowledgeBaseViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import Foundation

@MainActor
class KnowledgeBaseViewModel: ObservableObject {
    
    @Published public var topics: [Topic] = Topic.samples
    
    public var prominentTopics: [Topic] {
        topics.filter { $0.prominence == .prominent }
    }
    
    public var regularTopics: [Topic.Pair] {
        let regularTopics = topics.filter { $0.prominence == .regular }
        return pairUp(regularTopics)
    }
    
    public var subduedTopics: [Topic.Pair] {
        let subduedTopics = topics.filter { $0.prominence == .subdued }
        return pairUp(subduedTopics)
    }
    
    private func pairUp(_ topics: [Topic]) -> [Topic.Pair] {
        var pairs: [Topic.Pair] = []
        
        for i in 0...topics.count/2 {
            let leftIndex = i * 2
            let rightIndex = leftIndex + 1
            
            guard leftIndex < topics.count else { break }
            
            let left = topics[leftIndex]
            let right = rightIndex < topics.count ? topics[rightIndex] : nil
            
            pairs.append(.init(left: left, right: right))
        }
        
        return pairs
    }
    
}
