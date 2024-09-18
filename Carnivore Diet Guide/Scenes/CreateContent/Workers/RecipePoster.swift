//
//  RecipePoster.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/17/24.
//

import Foundation

protocol RecipePoster {
    func post(
        recipe: Recipe,
        feedItem: FeedItem
    ) async throws
}

class DefaultRecipePoster: RecipePoster {
    
    let postAction: (Recipe, FeedItem) async throws -> ()
    
    init(postAction: @escaping (Recipe, FeedItem) async throws -> Void) {
        self.postAction = postAction
    }
    
    func post(
        recipe: Recipe,
        feedItem: FeedItem
    ) async throws {
        try await postAction(recipe, feedItem)
    }
}

extension DefaultRecipePoster {
    static var forPreviewsWithSuccess: RecipePoster {
        DefaultRecipePoster { recipe, feedItem in
            try await Task.sleep(for: .seconds(1))
        }
    }
    
    static var forPreviewsWithFailure: RecipePoster {
        DefaultRecipePoster { recipe, feedItem in
            try await Task.sleep(for: .seconds(1))
            throw TextError("Test Error")
        }
    }
}
