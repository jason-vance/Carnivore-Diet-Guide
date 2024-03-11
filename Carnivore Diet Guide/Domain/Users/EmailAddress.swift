//
//  EmailAddress.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import ValueOf

//TODO: Use ConstrainedString with regex constraint
class EmailAddress: ValueOf<String> {
    
    static let emailRegex = /^[\p{L}0-9!#$%&'*+\/=?^_`{|}~-][\p{L}0-9.!#$%&'*+\/=?^_`{|}~-]{0,63}@[\p{L}0-9-]+(?:\.[\p{L}0-9-]{2,7})*$/
    
    required init(_ value: String) throws {
        try super.init(
            value,
            validator: Self.validate(value:)
        )
    }
    
    class func validate(value: String) -> Bool {
        return value.wholeMatch(of: Self.emailRegex) != nil
    }
}
