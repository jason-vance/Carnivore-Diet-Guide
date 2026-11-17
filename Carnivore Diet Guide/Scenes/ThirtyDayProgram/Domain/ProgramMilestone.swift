//
//  ProgramMilestone.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/17/26.
//

import Foundation

/// The celebration after the check-in that ends a week, or the whole program.
struct ProgramMilestone: Identifiable, Equatable {

    /// The review days: the end of each week, and day 30.
    let day: Int
    let checkInCount: Int
    let tasksDone: Int

    var id: Int { day }

    var isFinish: Bool { day == ProgramSchedule.length }

    var title: String {
        switch day {
        case 7: String(localized: "One week down")
        case 14: String(localized: "Two weeks down")
        case 21: String(localized: "Three weeks down")
        default: String(localized: "30 days done")
        }
    }

    var message: String {
        switch day {
        case 7: String(localized: "The first week is usually the hardest, and you're through it.")
        case 14: String(localized: "Two weeks of showing up. Your trends get clearer with every check-in.")
        case 21: String(localized: "Three weeks in, this is starting to be just how you eat.")
        default: String(localized: "You finished your first 30 days. Look back at how far you've come.")
        }
    }
}
