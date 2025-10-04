//
//  PersonName.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import ValueOf

class PersonName: ValueOf<String> {
    
    init(_ value: String) throws {
        try super.init(value, validator: Self.validate)
    }
    
    private static func validate(value: String) throws {
        guard hasAtLeastThreeChars(value) else {
            throw NSError(domain: "Name must be at least 3 characters long.", code: 0, userInfo: nil)
        }
        guard beginsAndEndsWithNonWhitespace(value) else {
            throw NSError(domain: "Name must not start or end with a whitespace character.", code: 0, userInfo: nil)
        }
    }
    
    private static func hasAtLeastThreeChars(_ value: String) -> Bool {
        value.count >= 3
    }
    
    private static func beginsAndEndsWithNonWhitespace(_ value: String) -> Bool {
        (value.first?.isWhitespace == false)
        &&
        (value.last?.isWhitespace == false)
    }
}
