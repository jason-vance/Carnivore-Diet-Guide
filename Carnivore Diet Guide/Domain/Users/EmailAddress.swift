//
//  EmailAddress.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import ValueOf

class EmailAddress: ValueOf<String> {
    
    override class func validate(value: String) -> Bool {
        let regex = /^[\p{L}0-9!#$%&'*+\/=?^_`{|}~-][\p{L}0-9.!#$%&'*+\/=?^_`{|}~-]{0,63}@[\p{L}0-9-]+(?:\.[\p{L}0-9-]{2,7})*$/
        return value.wholeMatch(of: regex) != nil
    }
}
