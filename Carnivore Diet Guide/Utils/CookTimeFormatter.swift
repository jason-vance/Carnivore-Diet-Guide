//
//  CookTimeFormatter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/13/24.
//

import Foundation

enum CookTimeFormatter {
    static func formatMinutes(_ cookTimeMinutes: Int) -> String {
        let hours = cookTimeMinutes / 60
        let minutes = cookTimeMinutes % 60
        
        var rv: String = ""
        if hours > 0 {
            rv += String(localized: "\(hours)hrs", comment: "Abbreviation for hours")
        }
        if minutes > 0 || hours == 0 {
            if hours > 0 {
                rv += " "
            }
            rv += String(localized: "\(minutes)mins", comment: "Abbreviation for minutes")
        }
        return rv
    }
}
