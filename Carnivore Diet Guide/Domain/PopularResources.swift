//
//  PopularResources.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation

struct PopularResources {
    
    private struct Resource {
        var id: String
        var score: UInt
    }
    
    private var map: [String: Resource] = [:]
    
    var isEmpty: Bool { map.isEmpty }
    
    func getSortedResourceIds() -> [String] {
        let resources = map.values
        
        return resources
            .sorted { $0.score > $1.score }
            .map { $0.id }
    }
    
    mutating func add(resourceId: String) {
        var current = map[resourceId] ?? .init(id: resourceId, score: 0)
        current.score += 1
        map[resourceId] = current
    }
}

extension PopularResources {
    static let sample: PopularResources = PopularResources(map: [
        "resourceId1": .init(id: "resourceId1", score: 4),
        "resourceId2": .init(id: "resourceId2", score: 3),
        "resourceId3": .init(id: "resourceId3", score: 2),
        "resourceId4": .init(id: "resourceId4", score: 1),
    ])
}
