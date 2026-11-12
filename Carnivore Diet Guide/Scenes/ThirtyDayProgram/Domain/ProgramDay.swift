//
//  ProgramDay.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation

/// One day of the First 30 Days program: a short lesson, one task, and what's normal around this point.
struct ProgramDay: Identifiable, Hashable {
    let number: Int
    let title: String
    let lesson: String
    let task: String
    let whatsNormal: String
    /// Firestore ids of related articles. Ids that no longer resolve are skipped when the day is shown.
    let articleIds: [String]

    var id: Int { number }
}

struct ProgramWeek: Identifiable, Hashable {
    let number: Int
    let title: String
    let days: ClosedRange<Int>

    var id: Int { number }
}

/// Navigation value for pushing a program day.
struct ProgramDayRoute: Hashable {
    let day: Int
}
