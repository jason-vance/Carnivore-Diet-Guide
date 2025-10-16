//
//  CommentProxyContainer.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/15/25.
//

import Foundation

class CommentProxyContainer: ObservableObject {
    
    @Published var proxyUserId: String?
    
    public static let shared = CommentProxyContainer()
    
    private init() { }
}
