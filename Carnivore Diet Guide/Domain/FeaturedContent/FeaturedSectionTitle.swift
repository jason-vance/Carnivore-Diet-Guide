//
//  FeaturedSectionTitle.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/9/24.
//

import Foundation

struct FeaturedSectionTitle {
    
    var title: String { wrapped.string }
    
    private let wrapped: NonEmptyString
    
    init?(_ title: String) {
        guard let title = NonEmptyString(string: title, minLength: 3) else { return nil }
        wrapped = title
    }
}
