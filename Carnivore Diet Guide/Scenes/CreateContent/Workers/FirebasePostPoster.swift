//
//  FirebasePostPoster.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import Foundation

extension DefaultPostPoster {
    static var forProd: PostPoster {
        DefaultPostPoster { post, feedItem in
            let postRepo = FirebasePostRepository()
            let feedItemRepo = FirebaseFeedItemRepository()
            
            do {
                try await postRepo.create(post: post)
            } catch {
                print("Failed to create Post. \(error.localizedDescription)")
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
