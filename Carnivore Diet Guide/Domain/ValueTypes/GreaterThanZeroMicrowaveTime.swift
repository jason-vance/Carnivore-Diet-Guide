//
//  GreaterThanZeroMicrowaveTime.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/7/24.
//

import Foundation
import ValueOf

class GreaterThanZeroMicrowaveTime: ValueOf<MicrowaveTime> {
    
    public static let `default`: GreaterThanZeroMicrowaveTime = .init(.init(hours: 0, minutes: 15)!)!
    
    override class func validate(value: MicrowaveTime) -> Bool { value.value > 0 }
    
    func formatted() -> String { value.formatted() }
}
