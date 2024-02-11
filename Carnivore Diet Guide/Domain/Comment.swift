//
//  Comment.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import Foundation

struct Comment: Identifiable {
    var id: String
    var userId: String
    var text: String
    var date: Date
}

extension Comment: Equatable {
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}

extension Comment {
    static let sample: Comment = samples[0]
    
    static let samples: [Comment] = [
        .init(
            id: UUID().uuidString,
            userId: UUID().uuidString,
            text: "This is a thoughtful comment. And, this comment has lots of lines. We need to test out how it looks after all.",
            date: .now
        ),
        .init(
            id: UUID().uuidString,
            userId: UUID().uuidString,
            text: "Cool!",
            date: Calendar.current.date(byAdding: .minute, value: -5, to: .now)!
        ),
        .init(
            id: UUID().uuidString,
            userId: UUID().uuidString,
            text: "I love this",
            date: Calendar.current.date(byAdding: .hour, value: -5, to: .now)!
        ),
        .init(
            id: UUID().uuidString,
            userId: UUID().uuidString,
            text: "This really helped",
            date: Calendar.current.date(byAdding: .day, value: -5, to: .now)!
        ),
        .init(
            id: UUID().uuidString,
            userId: UUID().uuidString,
            text: "I need more of this",
            date: Calendar.current.date(byAdding: .month, value: -5, to: .now)!
        )
    ]
}
