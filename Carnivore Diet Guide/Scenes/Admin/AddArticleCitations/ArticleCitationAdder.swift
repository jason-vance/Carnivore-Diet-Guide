//
//  ArticleCitationAdder.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/22/25.
//

import Foundation

class ArticleCitationAdder: ObservableObject {
    
    private let addCitationsToArticle: ([Article.Citation], Article) async throws -> Void
    
    init(addCitationsToArticle: @escaping ([Article.Citation], Article) async throws -> Void) {
        self.addCitationsToArticle = addCitationsToArticle
    }
    
    func add(citations: [Article.Citation], toArticle article: Article) async throws {
        try await addCitationsToArticle(citations, article)
    }
}

extension ArticleCitationAdder {
    
    static let forTesting: ArticleCitationAdder = .init() { _, _ in
        try await Task.sleep(for: .seconds(1))
    }
}
