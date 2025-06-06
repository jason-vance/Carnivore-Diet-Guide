//
//  ResourceSummary.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

extension Resource {
    struct Summary: Hashable {
        
        static let minTextLength: Int = 12
        static let maxTextLength: Int = 128

        let text: String
        
        init?(_ text: String) {
            // Trim whitespace
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for minimum and maximum length
            guard trimmedText.count >= Self.minTextLength, trimmedText.count <= Self.maxTextLength else {
                return nil
            }
            
            // Convert to lowercase
            self.text = trimmedText
        }
        
        static let sample: Resource.Summary = .init("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")!
    }
}
