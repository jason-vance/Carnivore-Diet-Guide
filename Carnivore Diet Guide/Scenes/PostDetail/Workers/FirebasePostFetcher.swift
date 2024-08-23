//
//  FirebasePostFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import Foundation

extension DefaultPostFetcher {
    static var forProd: PostFetcher {
        DefaultPostFetcher { postId in
            let postRepo = FirebasePostRepository()
            return try await postRepo.fetchPost(withId: postId)
        }
    }
}
