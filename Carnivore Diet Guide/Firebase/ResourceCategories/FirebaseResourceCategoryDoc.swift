//
//  FirebaseResourceCategoryDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseResourceCategoryDoc: Codable {
    
    @DocumentID var id: String?
    var image: String?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case image
        case name
    }
    
    public func toCategory() -> Resource.Category? {
        guard let id = id else { return nil }
        guard let name = name else { return nil }

        return .init(name, image: image, id: id)
    }
}

