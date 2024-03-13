//
//  MicrowaveTime.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/7/24.
//

import Foundation
import ValueOf

class MicrowaveTime: ValueOf<TimeInterval> {
    
    public static let zero = (try? MicrowaveTime(hours: 0, minutes: 0))!
    
    init(hours: Int, minutes: Int) throws {
        let hoursInSeconds = hours * 3600
        let minutesInSeconds = minutes * 60
        try super.init(
            TimeInterval(hoursInSeconds + minutesInSeconds),
            validator: Self.validate(value:)
        )
    }
    
    static func validate(value: TimeInterval) throws {
        if value < 0 {
            throw String(localized: "Must not be negative")
        }
    }
    
    func formatted() -> String {
        let totalSeconds = Int(value)
        
//        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        
        return String.init(format: "%d:%02d", hours, minutes)
    }
}
