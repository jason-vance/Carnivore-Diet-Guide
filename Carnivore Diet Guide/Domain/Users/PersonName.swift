//
//  PersonName.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import ValueOf

class PersonName: ConstrainedString {
    
    required init(_ value: String) throws {
        try super.init(
            value,
            validationConstraints: [ .minimumLength(3) ],
            formattingConstraints: [ .trimmed ]
        )
    }
}
