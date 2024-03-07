//
//  GreaterThanZeroInt.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/7/24.
//

import Foundation
import ValueOf

class GreaterThanZeroInt: ValueOf<Int> {
    
    public static let one: GreaterThanZeroInt = GreaterThanZeroInt(1)!
    
    override class func validate(value: Int) -> Bool { value > 0 }
}
