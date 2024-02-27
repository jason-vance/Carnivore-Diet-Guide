//
//  DifficultyLevel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/23/24.
//

import Foundation

extension Recipe {
    enum DifficultyLevel: String {
        case unknown
        case easy
        case intermediate
        case hard
        
        var uiString: String {
            switch self {
            case .unknown:
                return String(localized: "Unknown", comment: "Difficulty level is 'Unknown'")
            case .easy:
                return String(localized: "Easy", comment: "Difficulty level is 'Easy'")
            case .intermediate:
                return String(localized: "Intermediate", comment: "Difficulty level is 'Intermediate'")
            case .hard:
                return String(localized: "Hard", comment: "Difficulty level is 'Hard'")
            }
        }
        
        var explanation: String {
            switch self {
            case .unknown:
                return ""
            case .easy:
                return String(localized: "Requires only basic cooking skills and common ingredients.")
            case .intermediate:
                return String(localized: "Requires more experience, more prep, more cooking time, or ingredients you might not already have in your kitchen.")
            case .hard:
                return String(localized: "Requires more advanced skills and experience, maybe some special equipment, or hard to find ingredients.")
            }
        }
    }
}
