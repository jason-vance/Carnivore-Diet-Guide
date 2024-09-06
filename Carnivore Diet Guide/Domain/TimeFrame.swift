//
//  TimeFrame.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/6/24.
//

import Foundation

enum TimeFrame {
    case past24Hours
    case past7Days
    case past4Weeks
    
    public var numberOfDays: Int {
        switch self {
        case .past24Hours:
            1
        case .past7Days:
            7
        case .past4Weeks:
            28
        }
    }
}
