//
//  FirebaseKnowledgeBaseArticleSearcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/3/24.
//

import Foundation

class FirebaseKnowledgeBaseArticleSearcher: KnowledgeBaseArticleSearcher {
    
    let repo = FirebaseArticleRepository()
    
    //TODO: Do searches on device for now, no reaching out to Firebase (except for .all category)
    func searchArticles(in category: Resource.Category, query: String) async throws -> [Article] {
        let keywords = SearchKeyword.keywordsFrom(string: query)
        
        var articles = Dictionary<Article, UInt>()
        
        //TODO: Use a task group to do all searches at once
        
        for keyword in keywords {
            let results = try await repo.searchArticles(withKeyword: keyword)
            for result in results {
                articles[result.item] = articles[result.item, default: 0] + result.score
            }
        }
        
        return articles
            .sorted { $0.value > $1.value }
            .map { $0.key }
    }
}
