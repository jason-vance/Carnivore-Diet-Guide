//
//  NonEmptyString.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/9/24.
//

import Foundation

struct NonEmptyString {
    
    let string: String
    
    init?(string: String, minLength: Int) {
        // Trim whitespace
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for minimum length
        guard trimmedString.count >= minLength else { return nil }
        
        self.string = trimmedString
    }
}
