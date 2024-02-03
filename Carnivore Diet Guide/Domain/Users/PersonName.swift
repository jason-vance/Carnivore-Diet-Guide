//
//  PersonName.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import ValueOf

class PersonName: ValueOf<String> {
    
    override class func validate(value: String) -> Bool {
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
