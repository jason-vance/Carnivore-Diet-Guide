//
//  NonEmptyString.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/7/24.
//

import Foundation
import ValueOf

class NonEmptyString: ValueOf<String> {
    
    override class func validate(value: String) -> Bool { !value.isEmpty }
}
