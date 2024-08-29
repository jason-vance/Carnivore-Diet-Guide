//
//  FirebaseTopicDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseTopicDoc: Codable {
    
    @DocumentID var id: String?
    var imageUrl: String?
    var name: String?
    var prominence: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl
        case name
        case prominence
    }
    
    public func toTopic() -> Topic? {
        guard let id = id else { return nil }
        guard let name = name else { return nil }
        guard let prominence = Topic.Prominence.init(rawValue: prominence ?? "") else { return nil }
        let imageUrl = URL(string: imageUrl ?? "")
        
        return Topic(
            id: id,
            name: name,
            prominence: prominence,
            imageUrl: imageUrl
        )
    }
}

