//
//  FirebaseArticleDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseArticleDoc {
    
    @DocumentID var id: String?
    
    enum CodingKeys: String, CodingKey {
        case id
    }
    
}
