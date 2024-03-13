//
//  ResourceMarkdownContent.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/12/24.
//

import Foundation

class ResourceMarkdownContent: ConstrainedString {
    
    init(_ value: String) throws {
        try super.init(
            value,
            validationConstraints: [
                .minimumLength(3), //TODO: Should this actually be longer?
                .maximumLength(10000)
            ],
            formattingConstraints: [.trimmed]
        )
    }
}
