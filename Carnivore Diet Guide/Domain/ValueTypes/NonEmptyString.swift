//
//  NonEmptyString.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/7/24.
//

import Foundation
import ValueOf

class NonEmptyString: ValueOf<String> {
    
    required init(_ value: String) throws {
        try super.init(
            value,
            validator: Self.validate(value:)
        )
    }
    
    static func validate(value: String) -> Bool { !value.isEmpty }
}
