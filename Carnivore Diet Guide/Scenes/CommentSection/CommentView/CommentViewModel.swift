//
//  CommentViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import Foundation

@MainActor
class CommentViewModel: ObservableObject {
    
    //TODO: Load real imageUrl and user name
    @Published var userImageUrl: URL?
    @Published var userFullName: String = ""
    @Published var commentText: String = ""
    @Published var dateString: String = ""
    
    var comment: Comment? {
        didSet {
            setup()
        }
    }
    
    private func setup() {
        let comment = comment!
        
        userImageUrl = UserData.sample.profileImageUrl
        userFullName = UserData.sample.fullName!.value
        commentText = comment.text
        //TODO: Make this date easier to read (moments ago, yesterday, etc)
        dateString = comment.date.formatted()
    }
}
