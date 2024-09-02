//
//  FirebaseArticlePoster.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/1/24.
//

import Foundation

extension DefaultArticlePoster {
    static var forProd: ArticlePoster {
        DefaultArticlePoster { article, categories, keywords, feedItem in
            let articleRepo = FirebaseArticleRepository()
            let feedItemRepo = FirebaseFeedItemRepository()
            
            do {
                try await articleRepo.create(
                    article: article,
                    categories: categories,
                    keywords: keywords
                )
            } catch {
                print("Failed to create Article. \(error.localizedDescription)")
                throw error
            }
            
            do {
                try await feedItemRepo.create(feedItem: feedItem)
            } catch {
                print("Failed to create FeedItem. \(error.localizedDescription)")
                //Purposely ignoring error for this
            }
        }
    }
}
