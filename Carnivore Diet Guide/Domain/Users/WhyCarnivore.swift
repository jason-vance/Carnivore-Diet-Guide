//
//  WhyCarnivore.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/13/24.
//

import Foundation

struct WhyCarnivore {
    
    static let maxLength = 100
    
    let value: String
    
    init?(_ value: String?) {
        guard let value = value else { return nil }
        
        // Trim whitespace
        let trimmedString = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for maximum length
        guard trimmedString.count <= Self.maxLength else { return nil }
        
        self.value = trimmedString
    }
}
