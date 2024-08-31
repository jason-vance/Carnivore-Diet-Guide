//
//  SelectCategoryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import SwiftUI
import SwinjectAutoregistration
import SwiftUIFlowLayout

struct SelectCategoryView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    public let onSelect: (Resource.Category) -> ()
    
    @State private var categories: Set<Resource.Category> = []
    @State private var searchText: String = ""
    @State private var searchPresented: Bool = false
    
    private let categoryProvider = iocContainer~>ResourceCategoryProvider.self
    
    private func fetchCategories() {
        Task {
            do {
                let categories = try await categoryProvider.fetchAllCategories()
                withAnimation(.snappy) {
                    self.categories = Set(categories)
                }
            } catch {
                print("Failed to fetch categories: \(error.localizedDescription)")
                dismiss()
            }
        }
    }
    
    private func select(category: Resource.Category) {
        onSelect(category)
        dismiss()
    }
    
    private var filteredCategories: [Resource.Category] {
        if searchText.isEmpty {
            return Array(categories)
        }
        return categories
            .filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar("Select a Category")
                .padding(.top)
            ScrollView {
                VStack {
                    SearchArea()
                    FlowLayout(
                        mode: .vstack,
                        items: filteredCategories.sorted { $0.name < $1.name },
                        itemSpacing: 0
                    ) { category in
                        Button {
                            select(category: category)
                        } label: {
                            ResourceCategoryView(category)
                                .id(category.id)
                                .padding(.trailing, 8)
                                .padding(.bottom, 8)
                        }
                    }
                    if categories.isEmpty {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.accent)
                    }
                }
                .padding()
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
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        SelectCategoryView { selectedCategory in }
    }
}
