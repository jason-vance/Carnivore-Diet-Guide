//
//  KnowledgeBaseView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI
import Kingfisher
import SwinjectAutoregistration

struct KnowledgeBaseView: View {
    
    private let prominentItemHeight: CGFloat = 150
    private let regularItemHeight: CGFloat = 100
    private let subduedItemHeight: CGFloat = 72
    private let margin: CGFloat = 16
    
    @State private var navigationPath = NavigationPath()
    @State private var showSearchContent: Bool = false

    @StateObject private var model = KnowledgeBaseViewModel(
        categoryProvider: iocContainer~>ResourceCategoryProvider.self
    )
    
    @StateObject private var searchModel = KnowledgeBaseSearchViewModel(
        articleSearcher: iocContainer~>KnowledgeBaseArticleSearcher.self
    )
    
    @State var selectedCategory: Resource.Category = .featured
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                ScreenTitleBar(String(localized: "Knowledge Base"))
                ScrollView {
                    VStack {
                        SearchArea()
                        ListContent()
                    }
                }
                .overlay {
                    if model.isWorking {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.accent)
                    }
                }
            }
            .background(Color.background)
            .alert(model.alertMessage, isPresented: $model.showAlert) {}
            .alert(searchModel.alertMessage, isPresented: $searchModel.showAlert) {}
            .onChange(of: searchModel.searchPresented, initial: true) { _, showSearchContent in
                withAnimation(.snappy) {
                    if !showSearchContent {
                        searchModel.clearSearchResults()
                    }
                    self.showSearchContent = showSearchContent
                }
            }
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
        }
    }
    
    @ViewBuilder func SearchArea() -> some View {
        VStack(spacing: 0) {
            SearchBar(
                prompt: String(localized: "Articles, Guides, and more"),
                searchText: $searchModel.searchText,
                searchPresented: $searchModel.searchPresented,
                action: { searchModel.doSearchIn(category: selectedCategory) }
            )
            .padding(.top)
            .padding(.horizontal)
            ResourceCategoryPicker(selectedCategory: $selectedCategory, resourceType: .article)
        }
    }
    
    @ViewBuilder func ListContent() -> some View {
        if showSearchContent || searchModel.searchResults != nil {
            SearchContent()
        } else {
            ArticlesInCategoryView(
                navigationPath: $navigationPath,
                category: selectedCategory
            )
        }
    }
    
    @ViewBuilder func SearchContent() -> some View {
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        VStack {
            if let searchResults = searchModel.searchResults {
                if searchResults.isEmpty {
                    ContentUnavailableView(
                        "Nothing could be found matching\n\"\(searchModel.searchText)\"",
                        systemImage: "magnifyingglass"
                    )
                    .foregroundStyle(Color.text)
                } else {
                    Text("\(searchResults.count) articles found")
                    LazyVGrid(columns: columns) {
                        ForEach(searchResults) { result in
                            ArticleItemView(result)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .overlay {
            if searchModel.isSearching {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.accent)
            }
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        KnowledgeBaseView()
    }
}
