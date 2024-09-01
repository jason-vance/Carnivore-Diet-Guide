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
    @Published public var articleCategories: [Resource.Category] = Resource.Category.contentAgnosticCategories
    
    @Published public var showAlert: Bool = false
    @Published public var alertMessage: String = ""
    
    private let categoryProvider: ResourceCategoryProvider
    
    init(
        categoryProvider: ResourceCategoryProvider
    ) {
        self.categoryProvider = categoryProvider
        
        fetchCategories()
    }
    
    private func fetchCategories() {
        Task { [self] in
            var categories = Resource.Category.contentAgnosticCategories
            
            do {
                let contentCategories = try await categoryProvider.fetchAllCategories()
                    .sorted { $0.name < $1.name }
                categories.append(contentsOf: contentCategories)
            } catch {
                print("KnowledgeBaseViewModel: Failed to fetch categories. \(error.localizedDescription)")
            }
            
            articleCategories = categories
        }
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
}
