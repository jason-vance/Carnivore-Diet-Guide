//
//  Topic.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

struct Topic: Identifiable {
    
    struct Pair: Identifiable {
        var id: String { left.id }
        let left: Topic
        let right: Topic?
    }
    
    enum Prominence: String {
        case regular
        case prominent
        case subdued
    }
    
    let id: String
    let name: String
    let prominence: Prominence
    let imageUrl: URL?
}

extension Topic {
    static let samples: [Topic] = [
        Topic(
            id: UUID().uuidString,
            name: "The Basics",
            prominence: .prominent,
            imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/KnowledgeBase%2FTopicImages%2Feggs.jpg?alt=media&token=fe734a05-7cb4-41b9-b597-53ab24d6efaf")!
        ),
        Topic(
            id: UUID().uuidString,
            name: "Health Benefits",
            prominence: .regular,
            imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/KnowledgeBase%2FTopicImages%2FHealthBenefits.jpg?alt=media&token=23f4b821-5af7-4cff-a9bb-12f5c6c96e68")!
        ),
        Topic(
            id: UUID().uuidString,
            name: "Challenges",
            prominence: .regular,
            imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/KnowledgeBase%2FTopicImages%2Fchallenges.jpg?alt=media&token=04c3fd92-387b-4236-80a2-d0c13fabeff4")!
        ),
        Topic(
            id: UUID().uuidString,
            name: "Cooking",
            prominence: .regular,
            imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/KnowledgeBase%2FTopicImages%2Fcooking.jpg?alt=media&token=af6bd64d-df33-4312-8e93-67e2a03b6e4c")!
        ),
        Topic(
            id: UUID().uuidString,
            name: "Variations of Carnivore",
            prominence: .regular,
            imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/KnowledgeBase%2FTopicImages%2Fvariations.jpg?alt=media&token=b20f0894-b9d7-459f-b012-5d8c55062f9a")!
        ),
        Topic(
            id: UUID().uuidString,
            name: "Scientific Research",
            prominence: .regular,
            imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/KnowledgeBase%2FTopicImages%2FscienceResearch.jpg?alt=media&token=40b88788-416e-4c95-bcc3-febd96125e52")!
        ),
        Topic(
            id: UUID().uuidString,
            name: "Case Studies",
            prominence: .regular,
            imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/KnowledgeBase%2FTopicImages%2FcaseStudies.jpg?alt=media&token=92809b85-20bd-433d-a592-1f564314a893")!
        ),
        Topic(
            id: UUID().uuidString,
            name: "Vitamins & Minerals",
            prominence: .regular,
            imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/KnowledgeBase%2FTopicImages%2Fvitamins.jpg?alt=media&token=349a9c7b-18c8-4bde-a48f-dbc238bd24a9")!
        ),
        Topic(
            id: UUID().uuidString,
            name: "Hydration",
            prominence: .regular,
            imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/KnowledgeBase%2FTopicImages%2Fhydration.jpg?alt=media&token=c5219beb-9d76-4ebd-bce2-391fd6228629")!
        ),
        Topic(
            id: UUID().uuidString,
            name: "Exercise",
            prominence: .regular,
            imageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/KnowledgeBase%2FTopicImages%2Fexercise.jpg?alt=media&token=8a016cbb-0718-456b-b163-b5f6f3e3fb86")!
        ),
        Topic(
            id: UUID().uuidString,
            name: "Other",
            prominence: .subdued,
            imageUrl: nil
        ),
        Topic(
            id: UUID().uuidString,
            name: "Testing Subdued Long Title",
            prominence: .subdued,
            imageUrl: nil
        )
    ]
}
