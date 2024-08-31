//
//  SelectCategoryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import SwiftUI
import SwinjectAutoregistration

struct SelectCategoryView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    public let onSelect: (Resource.Category) -> ()
    
    @State private var categories: [Resource.Category] = []
    @State private var searchText: String = ""
    @State private var searchPresented: Bool = false
    
    private let categoryProvider = iocContainer~>ResourceCategoryProvider.self
    
    private func fetchCategories() {
        Task {
            do {
                categories = try await categoryProvider.fetchAllCategories()
            } catch {
                print("Failed to fetch categories: \(error.localizedDescription)")
                dismiss()
            }
        }
    }
    
    private var filteredCategories: [Resource.Category] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar("Select a Category")
                .padding(.top)
            SearchArea()
            ScrollView {
                VStack {
                    //TODO: Put this into a flow layout
                    ForEach(filteredCategories) { category in
                        ResourceCategoryView(category)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.background)
        .onAppear { fetchCategories() }
    }
    
    @ViewBuilder func SearchArea() -> some View {
        SearchBar(
            prompt: String(localized: "Search for a category"),
            searchText: $searchText,
            searchPresented: $searchPresented,
            action: {}
        )
        .padding()
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        SelectCategoryView { selectedCategory in }
    }
}
