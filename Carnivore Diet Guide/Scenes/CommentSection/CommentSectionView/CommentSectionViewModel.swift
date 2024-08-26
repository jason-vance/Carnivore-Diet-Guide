//
//  CommentSectionViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import Foundation
import Combine

@MainActor
class CommentSectionViewModel: ObservableObject {
    
    @Published var comments: [Comment] = []
    @Published var isSendingComment: Bool = false
    
    private let currentUserIdProvider: CurrentUserIdProvider
    private let commentProvider: CommentProvider
    private let commentSender: CommentSender
    private let commentActivityTracker: ResourceCommentActivityTracker
    
    private var commentSub: AnyCancellable?
    
    init(
        currentUserIdProvider: CurrentUserIdProvider,
        commentProvider: CommentProvider,
        commentSender: CommentSender,
        commentActivityTracker: ResourceCommentActivityTracker
    ) {
        self.currentUserIdProvider = currentUserIdProvider
        self.commentProvider = commentProvider
        self.commentSender = commentSender
        self.commentActivityTracker = commentActivityTracker
    }
    
    func sendComment(
        text: String,
        toResource resource: Resource
    ) async throws {
        guard !text.isEmpty else { throw "Comment text is empty" }
        
        isSendingComment = true
        try await commentSender.sendComment(text: text, toResource: resource)
        isSendingComment = false
        
        addCommentActivity(onResource: resource)
    }
    
    func startListeningForComments(onResource resource: Resource) {
        commentSub = commentProvider.listenForCommentsOrderedByDate(
            onResource: resource,
            onUpdate: onUpdate(comments:),
            onError: nil
        )
    }
    
    private func onUpdate(comments: [Comment]) {
        self.comments = comments
    }
    
    private func addCommentActivity(onResource resource: Resource) {
        Task {
            guard let userId = currentUserIdProvider.currentUserId else { return }
            
            try? await commentActivityTracker.resource(resource, wasCommentedOnByUser: userId)
        }
    }
}
