//
//  FirebaseCommentCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import Foundation
import Combine

class FirebaseCommentCountProvider: CommentCountProvider {
    
    private let commentsRepo = FirebaseCommentRepository()
    
    @Published var commentCount: UInt = 0
    var commentCountPublisher: Published<UInt>.Publisher { $commentCount }
    
    private var commentCountListener: AnyCancellable?
    
    public func startListening(to resource: Resource) {
        commentCountListener = commentsRepo.listenToCommentCountOf(resource: resource) { [weak self] count in
            self?.commentCount = count
        } onError: { error in
            print("Failed to retrieve comment count: \(error.localizedDescription)")
        }
    }
}
