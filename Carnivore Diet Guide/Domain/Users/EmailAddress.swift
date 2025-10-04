//
//  EmailAddress.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import ValueOf

class EmailAddress: ValueOf<String> {
    
    init(_ value: String) throws {
        try super.init(value, validator: Self.validate)
    }
    
    private static func validate(value: String) throws {
        let regex = /^[\p{L}0-9!#$%&'*+\/=?^_`{|}~-][\p{L}0-9.!#$%&'*+\/=?^_`{|}~-]{0,63}@[\p{L}0-9-]+(?:\.[\p{L}0-9-]{2,7})*$/
        guard value.wholeMatch(of: regex) != nil else {
            throw NSError(domain: "Email address must be a valid email address", code: 0, userInfo: nil)
        }
    }
}
