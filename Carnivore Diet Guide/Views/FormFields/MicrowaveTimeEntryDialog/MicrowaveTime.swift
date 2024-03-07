//
//  MicrowaveTime.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/7/24.
//

import Foundation
import ValueOf

class MicrowaveTime: ValueOf<TimeInterval> {
    
    public static let zero = MicrowaveTime(0)!
    
    convenience init?(hours: Int, minutes: Int) {
        let hoursInSeconds = hours * 3600
        let minutesInSeconds = minutes * 60
        self.init(TimeInterval(hoursInSeconds + minutesInSeconds))
    }
    
    override class func validate(value: TimeInterval) -> Bool {
        value >= 0
    }
    
    func formatted() -> String {
        let totalSeconds = Int(value)
        
//        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        
        return String.init(format: "%d:%02d", hours, minutes)
    }
}
