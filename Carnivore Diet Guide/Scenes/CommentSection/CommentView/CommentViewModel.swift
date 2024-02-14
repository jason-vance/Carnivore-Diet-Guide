//
//  CommentViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import Foundation
import SwinjectAutoregistration

@MainActor
class CommentViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var commentIsMine: Bool = false
    @Published var userImageUrl: URL?
    @Published var userFullName: String = ""
    @Published var commentText: String = ""
    @Published var dateString: String = ""
    
    @Published var showError: Bool = false
    @Published var errorMessage: String = "errorMessage"
    
    private let currentUserIdProvider = iocContainer~>CurrentUserIdProvider.self
    private let userFetcher = iocContainer~>UserFetcher.self
    private let commentDeleter = iocContainer~>CommentDeleter.self
    private let commentReporter = iocContainer~>CommentReporter.self

    private var comment: Comment?
    private var resource: CommentSectionView.Resource?
    
    func set(comment: Comment, resource: CommentSectionView.Resource) {
        self.comment = comment
        self.resource = resource
        
        commentIsMine = comment.userId == currentUserIdProvider.currentUserId
        commentText = comment.text
        dateString = comment.date.timeAgoString()
        
        fetchUserData(userId: comment.userId)
    }
    
    private func fetchUserData(userId: String) {
        Task {
            isLoading = true
            do {
                let userData = try await userFetcher.fetchUser(userId: userId)
                userImageUrl = userData.profileImageUrl
                userFullName = userData.fullName?.value ?? "Unknown User"
            }
            isLoading = false
        }
    }
    
    func deleteComment() {
        Task {
            do {
                guard let comment = comment else { throw "`comment` was nil" }
                guard let resource = resource else { throw "`resource` was nil" }

                try await commentDeleter.deleteComment(comment, onResource: resource)
            } catch {
                show(errorMessage: "Comment could not be deleted: \(error.localizedDescription)")
            }
        }
    }
    
    func reportComment() {
        Task {
            do {
                guard let comment = comment else { throw "`comment` was nil" }
                guard let resource = resource else { throw "`resource` was nil" }
                guard let reporterId = currentUserIdProvider.currentUserId else { throw "`reporterId` was nil" }

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
