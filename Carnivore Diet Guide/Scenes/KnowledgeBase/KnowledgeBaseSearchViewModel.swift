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
    
    //TODO: Get real search results
    @Published var searchResults: [Article] = [ .sample, .sample2 ]
    
    func doSearch() {
        
    }
}
