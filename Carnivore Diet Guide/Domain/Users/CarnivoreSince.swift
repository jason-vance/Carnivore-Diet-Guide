//
//  CarnivoreSince.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/13/24.
//

import Foundation

struct CarnivoreSince {
    
    let date: Date
    
    init?(_ date: Date?) {
        guard let date = date else { return nil }
        self.date = date
    }
    
    var value: String {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate the difference between the input date and now
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day], from: date, to: now)
        
        // Check for "Last Year" and "X Years Ago"
        if let year = components.year {
            if year == 1 {
                return "Last Year"
            } else if year > 1 {
                return "\(year) Years Ago"
            }
        }
        
        // Check for "Last Month" and "X Months Ago"
        if let month = components.month {
            if month == 1 {
                return "Last Month"
            } else if month > 1 {
                return "\(month) Months Ago"
            }
        }
        
        // Check for "Last Week" and "X Weeks Ago"
        if let weekOfYear = components.weekOfYear {
            if weekOfYear == 1 {
                return "Last Week"
            } else if weekOfYear > 1 {
                return "\(weekOfYear) Weeks Ago"
            }
        }
        
        // Check for "Yesterday"
        if let day = components.day {
            if day == 1 {
                return "Yesterday"
            } else if day > 1 {
                return "This Week"
            }
        }
        
        // Default to "Today" if none of the above conditions are met
        return "Today"
    }
}
