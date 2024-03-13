//
//  GreaterThanZeroMicrowaveTime.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/7/24.
//

import Foundation
import ValueOf

class GreaterThanZeroMicrowaveTime: ValueOf<MicrowaveTime> {
    
    public static let `default` = (try? GreaterThanZeroMicrowaveTime((try? .init(hours: 0, minutes: 15))!))!
    
    required init(_ value: MicrowaveTime) throws {
        try super.init(
            value,
            validator: Self.validate(value:)
        )
    }
    
    class func validate(value: MicrowaveTime) throws {
        if value.value <= 0 {
            throw "Must be greater than zero"
        }
    }
    
    func formatted() -> String { value.formatted() }
}
