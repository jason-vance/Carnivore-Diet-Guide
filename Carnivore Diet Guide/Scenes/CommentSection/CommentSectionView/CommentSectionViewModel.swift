//
//  CommentSectionViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

@MainActor
class CommentSectionViewModel: ObservableObject {
    
    @Published var comments: [Comment] = []
    @Published var isSendingComment: Bool = false
    
    private let commentProvider = iocContainer~>CommentProvider.self
    private let commentSender = iocContainer~>CommentSender.self
    
    private var commentSub: AnyCancellable?
    
    func sendComment(
        text: String,
        toResource resource: CommentSectionView.Resource
    ) async throws {
        guard !text.isEmpty else { throw "Comment text is empty" }
        
        isSendingComment = true
        try await commentSender.sendComment(text: text, toResource: resource)
        isSendingComment = false
        
        addCommentActivity(onResource: resource)
    }
    
    func startListeningForComments(onResource resource: CommentSectionView.Resource) {
        commentSub = commentProvider.listenForCommentsOrderedByDate(
            onResource: resource,
            onUpdate: onUpdate(comments:),
            onError: nil
        )
    }
    
    private func onUpdate(comments: [Comment]) {
        self.comments = comments
    }
    
    private func addCommentActivity(onResource resource: CommentSectionView.Resource) {
        Task {
            guard let userId = (iocContainer~>CurrentUserIdProvider.self).currentUserId else { return }
            let commentActivityTracker = iocContainer~>ResourceCommentActivityTracker.self
            
            try? await commentActivityTracker.resource(resource, wasCommentedOnByUser: userId)
        }
    }
}
