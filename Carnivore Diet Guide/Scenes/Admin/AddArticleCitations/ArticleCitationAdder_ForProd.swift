//
//  ArticleCitationAdder_ForProd.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/22/25.
//

import Foundation

extension ArticleCitationAdder {
    static let forProd = ArticleCitationAdder(
        addCitationsToArticle: { citations, article in
            try await FirebaseArticleRepository().add(citations: citations, toArticle: article)
        }
    )
}
