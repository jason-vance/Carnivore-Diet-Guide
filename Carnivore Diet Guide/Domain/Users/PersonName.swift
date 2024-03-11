//
//  PersonName.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import ValueOf

//TODO: Make this a ConstrainedString
class PersonName: ValueOf<String> {
    
    required init(_ value: String) throws {
        try super.init(
            value,
            validator: Self.validate(value:)
        )
    }
    
    class func validate(value: String) -> Bool {
        hasAtLeastThreeChars(value)
        &&
        beginsAndEndsWithNonWhitespace(value)
    }
    
    private class func hasAtLeastThreeChars(_ value: String) -> Bool {
        value.count >= 3
    }
    
    private class func beginsAndEndsWithNonWhitespace(_ value: String) -> Bool {
        (value.first?.isWhitespace == false)
        &&
        (value.last?.isWhitespace == false)
    }
}
