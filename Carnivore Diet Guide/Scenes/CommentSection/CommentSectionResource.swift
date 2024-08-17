//
//  CommentSectionResource.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/16/24.
//

import Foundation


struct CommentSectionResource: Equatable {
    
    enum ResourceType: String {
        case recipe
        case post
    }
    
    var id: String
    var type: ResourceType
}
