//
//  CurrentUsersPostsFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/11/24.
//

import Foundation
import SwinjectAutoregistration

protocol CurrentUsersPostsFetcher {
    var canFetchMorePublisher: Published<Bool>.Publisher { get }
    var postsPublisher: Published<[Post]>.Publisher { get }
    func fetchMorePosts()
    func refresh()
}

class DefaultCurrentUsersPostsFetcher: CurrentUsersPostsFetcher {
    
    static let instance: DefaultCurrentUsersPostsFetcher = { .init() }()
    private static let limit = 10
    
    private var cursor: PostsFetcherCursor? = nil
    @Published var posts: [Post] = []
    @Published var canFetchMore: Bool = true
    
    var postsPublisher: Published<[Post]>.Publisher { $posts }
    var canFetchMorePublisher: Published<Bool>.Publisher { $canFetchMore }
        
    private let postsFetcher = iocContainer~>PostsFetcher.self
    private let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    
    private var userId: String { userIdProvider.currentUserId! }
    
    private init() {
        resetProperties()
    }
    
    private func resetProperties() {
        cursor = nil
        posts = []
        canFetchMore = true
    }
    
    func refresh() {
        resetProperties()
    }

    func fetchMorePosts() {
        Task {
            do {
                let newPosts = try await postsFetcher.fetchPosts(
                    byUser: userId,
                    after: &cursor,
                    limit: Self.limit
                )
                if newPosts.isEmpty {
                    canFetchMore = false
                }
                posts.append(contentsOf: newPosts)
            } catch {
                print("CurrentUsersPostsFetcher: Failed to fetch more posts. \(error.localizedDescription)")
            }
        }
    }
}
