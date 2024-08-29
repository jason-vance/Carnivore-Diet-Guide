//
//  KnowledgeBaseViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import Foundation

@MainActor
class KnowledgeBaseViewModel: ObservableObject {
    
    @Published public var isWorking: Bool = false
    @Published public var topics: [Topic] = []
    
    @Published public var showAlert: Bool = false
    @Published public var alertMessage: String = ""
    
    private let topicProvider: TopicProvider
    
    init(topicProvider: TopicProvider) {
        self.topicProvider = topicProvider
    }
    
    public var prominentTopics: [Topic] {
        topics
            .filter { $0.prominence == .prominent }
            .sorted { $0.name < $1.name }
    }
    
    public var regularTopics: [Topic.Pair] {
        let regularTopics = topics
            .filter { $0.prominence == .regular }
            .sorted { $0.name < $1.name }
        return pairUp(regularTopics)
    }
    
    public var subduedTopics: [Topic.Pair] {
        let subduedTopics = topics
            .filter { $0.prominence == .subdued }
            .sorted { $0.name < $1.name }
        return pairUp(subduedTopics)
    }
    
    private func pairUp(_ topics: [Topic]) -> [Topic.Pair] {
        var pairs: [Topic.Pair] = []
        
        for i in 0...topics.count/2 {
            let leftIndex = i * 2
            let rightIndex = leftIndex + 1
            
            guard leftIndex < topics.count else { break }
            
            let left = topics[leftIndex]
            let right = rightIndex < topics.count ? topics[rightIndex] : nil
            
            pairs.append(.init(left: left, right: right))
        }
        
        return pairs
    }
    
    public func fetchTopics() {
        isWorking = true
        Task {
            do {
                topics = try await topicProvider.fetchTopics()
            } catch {
                show(alert: "Failed to fetch Knowledge Base content. \(error.localizedDescription)")
            }
            DispatchQueue.main.async { [weak self] in self?.isWorking = false }
        }
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
}
