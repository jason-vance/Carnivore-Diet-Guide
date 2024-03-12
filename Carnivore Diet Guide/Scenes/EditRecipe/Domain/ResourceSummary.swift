//
//  ResourceSummary.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/12/24.
//

import Foundation

class ResourceSummary: ConstrainedString {
    
    init(_ value: String) throws {
        try super.init(
            value,
            validationConstraints: [
                .minimumLength(3),
                .maximumLength(1000)
            ],
            formattingConstraints: [.trimmed]
        )
    }
}
