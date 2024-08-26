//
//  CommentCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import Foundation

protocol CommentCountProvider {
    var commentCountPublisher: Published<UInt>.Publisher { get }
    func startListening(to resource: Resource)
}

class MockCommentCountProvider: CommentCountProvider {
    
    @Published var commentCount: UInt = 0
    var commentCountPublisher: Published<UInt>.Publisher { $commentCount }
    
    func startListening(to resource: Resource) {}
}

