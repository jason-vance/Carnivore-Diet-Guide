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
        
        func toUiString() -> String {
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
    }
}
