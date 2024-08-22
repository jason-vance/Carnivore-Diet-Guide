//
//  DateExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/10/24.
//

import Foundation

extension Date {
    func timeAgoString(fromDate: Date = .now) -> String {
        let secondsPerMinute = 60
        let secondsPerHour = secondsPerMinute * 60
        let secondsPerDay = secondsPerHour * 24
        let secondsPerWeek = secondsPerDay * 7

        let secondsAgo = Int(self.distance(to: fromDate))
        
        if secondsAgo >= secondsPerWeek {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM yyyy"
            return formatter.string(from: self)
        }
        
        if secondsAgo >= secondsPerDay {
            let days = secondsAgo / secondsPerDay
            return String(localized: "\(days) days ago")
        }
        
        if secondsAgo >= secondsPerHour {
            let hours = secondsAgo / secondsPerHour
            return String(localized: "\(hours) hours ago")
        }
        
        if secondsAgo >= 2 * secondsPerMinute {
            let minutes = secondsAgo / secondsPerMinute
            return String(localized: "\(minutes) minutes ago")
        }
        
        return String(localized: "moments ago")
    }
    
    func toBasicUiString() -> String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        }
        if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        }
        if Calendar.current.isDateInTomorrow(self) {
            return "Tomorrow"
        }
        return self.formatted(date: .abbreviated, time: .omitted)
    }
}
