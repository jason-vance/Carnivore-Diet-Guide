//
//  GreaterThanZeroInt.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/7/24.
//

import Foundation
import ValueOf

class GreaterThanZeroInt: ValueOf<Int> {
    
    public static let one = (try? GreaterThanZeroInt(1))!
    
    required init(_ value: Int) throws {
        try super.init(
            value,
            validator: Self.validate(value:))
    }
    
    static func validate(value: Int) throws {
        if value <= 0 {
            throw String(localized: "Must be greater than zero")
        }
    }
}
