//
//  CommentViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

@MainActor
class CommentViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var commentIsMine: Bool = false
    @Published var userImageUrl: URL?
    @Published var username: String = ""
    @Published var commentText: String = ""
    @Published var dateString: String = ""
    
    @Published var showError: Bool = false
    @Published var errorMessage: String = "errorMessage"
    
    private let currentUserIdProvider = iocContainer~>CurrentUserIdProvider.self
    private let userFetcher = iocContainer~>UserFetcher.self
    private let commentDeleter = iocContainer~>CommentDeleter.self
    private let commentReporter = iocContainer~>CommentReporter.self

    private var comment: Comment?
    private var resource: Resource?
    
    private var sub: AnyCancellable? = nil
    
    func set(comment: Comment, resource: Resource) {
        self.comment = comment
        self.resource = resource
        
        commentIsMine = comment.userId == currentUserIdProvider.currentUserId
        commentText = comment.text
        dateString = comment.date.timeAgoString()
        
        fetchUserData(userId: comment.userId)
    }
    
    private func fetchUserData(userId: String) {
        isLoading = true
        sub = userFetcher.fetchUser(userId: userId)
            .receive(on: RunLoop.main)
            .sink { [weak self] userData in
                self?.userImageUrl = userData.profileImageUrl
                self?.username = userData.username?.value ?? "Unknown User"
                self?.isLoading = false
            }
    }
    
    func deleteComment() {
        Task {
            do {
                guard let comment = comment else { throw TextError("`comment` was nil") }
                guard let resource = resource else { throw TextError("`resource` was nil") }

                try await commentDeleter.deleteComment(comment, onResource: resource)
                
                userImageUrl = nil
                username = "[Deleted]"
                commentText = "[Deleted]"
                dateString = ""
            } catch {
                show(errorMessage: "Comment could not be deleted: \(error.localizedDescription)")
            }
        }
    }
    
    func reportComment() {
        Task {
            do {
                guard let comment = comment else { throw TextError("`comment` was nil") }
                guard let resource = resource else { throw TextError("`resource` was nil") }
                guard let reporterId = currentUserIdProvider.currentUserId else { throw TextError("`reporterId` was nil") }

                try await commentReporter.reportComment(comment, onResource: resource, reportedBy: reporterId)
                show(errorMessage: "Comment was reported")
            } catch {
                show(errorMessage: "Comment could not be reported: \(error.localizedDescription)")
            }
        }
    }
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
}
