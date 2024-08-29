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
    
    @Published var searchResults: [KnowledgeBaseContent] = [ .sample, .sample2 ]
    
    func doSearch() {
        
    }
}
