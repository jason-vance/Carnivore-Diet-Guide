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
        
    @State private var navigationPath = NavigationPath()

    @State var selectedCategory: Resource.Category = .featured
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                TopBar()
                LimitedTimeOfferButton()
                ScrollView() {
                    VStack(spacing: 0) {
                        CategoryPicker()
                        ListContent()
                    }
                }
                .scrollIndicators(.hidden)
            }
            .background(Color.background)
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
        }
    }
    
    @ViewBuilder func TopBar() -> some View {
        ScreenTitleBar(Bundle.main.bundleName ?? String(localized: "Home"))
    }
    
    @ViewBuilder func CategoryPicker() -> some View {
        VStack(spacing: 0) {
            ResourceCategoryPicker(selectedCategory: $selectedCategory, resourceType: .article)
        }
    }
    
    @ViewBuilder func ListContent() -> some View {
        if selectedCategory == .featured {
            FeaturedArticlesView(navigationPath: $navigationPath)
        } else if ContentAgnosticArticlesView.canHandle(category: selectedCategory) {
            ContentAgnosticArticlesView(
                navigationPath: $navigationPath,
                category: selectedCategory
            )
        } else {
            ArticlesInCategoryView(
                navigationPath: $navigationPath,
                category: selectedCategory
            )
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
