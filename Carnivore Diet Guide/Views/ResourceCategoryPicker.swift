//
//  ResourceCategoryPicker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/3/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ResourceCategoryPicker: View {
    
    @Binding public var selectedCategory: Resource.Category
    @State public var resourceType: Resource.ResourceType
    
    @State private var categories: [Resource.Category] = Resource.Category.contentAgnosticCategories
    
    private let categoryProvider = iocContainer~>ResourceCategoryProvider.self
    
    private func fetchCategories() {
        Task {
            do {
                let baseCategories = Resource.Category.contentAgnosticCategories
                let categories = try await categoryProvider.fetchAllCategories(forType: resourceType)
                self.categories = baseCategories + categories.sorted { $0.name < $1.name }
            } catch {
                print("ResourceCategoryPicker failed to fetch categories. \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(categories) { category in
                    Button {
                        withAnimation(.snappy) { selectedCategory = category }
                    } label: {
                        ResourceCategoryView(category)
                            .highlighted(selectedCategory == category)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            fetchCategories()
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        StatefulPreviewContainer(Resource.Category.featured) { category in
            ResourceCategoryPicker(selectedCategory: category, resourceType: .article)
        }
    }
}
