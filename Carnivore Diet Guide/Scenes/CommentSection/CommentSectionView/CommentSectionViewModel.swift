//
//  CommentSectionViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import Foundation

@MainActor
class CommentSectionViewModel: ObservableObject {
    
    //TODO: Load real comments
    @Published var comments: [Comment] = Comment.samples
    
}
