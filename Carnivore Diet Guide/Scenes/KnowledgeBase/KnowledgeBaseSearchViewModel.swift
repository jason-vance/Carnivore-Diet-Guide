//
//  KnowledgeBaseSearchViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

@MainActor
class KnowledgeBaseSearchViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var searchPresented: Bool = false
    @Published var isSearching: Bool = false
    
    @Published public var showAlert: Bool = false
    @Published public var alertMessage: String = ""
    
    @Published var searchResults: [Article]? = nil
    
    private let articleSearcher: KnowledgeBaseArticleSearcher
    
    init(
        articleSearcher: KnowledgeBaseArticleSearcher
    ) {
        self.articleSearcher = articleSearcher
    }
    
    func doSearchIn(category: Resource.Category) {
        isSearching = true
        
        Task {
            do {
                searchResults = try await articleSearcher.searchArticles(in: category, query: searchText)
            } catch {
                show(alert: "Failed to complete search: \(error.localizedDescription)")
                searchResults = []
            }
            
            DispatchQueue.main.async { self.isSearching = false }
        }
    }
    
    func clearSearchResults() {
        searchResults = nil
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
}
