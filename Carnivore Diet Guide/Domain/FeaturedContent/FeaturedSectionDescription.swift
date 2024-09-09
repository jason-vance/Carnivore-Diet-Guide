//
//  FeaturedSectionDescription.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/9/24.
//

import Foundation

struct FeaturedSectionDescription {
    
    var description: String { wrapped.string }
    
    private let wrapped: NonEmptyString
    
    init?(_ description: String) {
        guard let description = NonEmptyString(string: description, minLength: 5) else { return nil }
        wrapped = description
    }
}
