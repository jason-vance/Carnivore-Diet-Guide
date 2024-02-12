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
    @Published var userImageUrl: URL?
    @Published var userFullName: String = ""
    @Published var commentText: String = ""
    @Published var dateString: String = ""
    
    private let userFetcher = iocContainer~>UserFetcher.self
    
    var comment: Comment? {
        didSet {
            setup()
        }
    }
    
    private func setup() {
        let comment = comment!
        
        commentText = comment.text
        dateString = comment.date.timeAgoString()
        
        fetchUserData(userId: comment.userId)
    }
    
    func fetchUserData(userId: String) {
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
}
